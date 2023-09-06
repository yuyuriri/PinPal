//
//  TopmenuViewController.swift
//  PinPal
//
//  Created by 滑川裕里瑛 on 2023/09/03.
//

import UIKit
import GoogleMaps
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import FirebaseAuth

class TopmenuViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, GMSMapViewDelegate {
    
    var markers = [GMSMarker]()
    
    var rooms = [RoomData]()
    
    let db = Firestore.firestore()
    let decoder = JSONDecoder()
    
    let imageRef = Storage.storage().reference()
    
    
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    //多分ルームごとのデータの保存場所
    var selectedroom: RoomData!
    
    private var mapView: GMSMapView!
    
    //一番最初だけ呼び出し
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // MARK: 後でやる
        let camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(Float.random(in: -90...90)), longitude:CLLocationDegrees(Float.random(in: -180...180)), zoom: 10.0)
        mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        view.addSubview(mapView)
        view.sendSubviewToBack(mapView)

        collectionView.delaysContentTouches = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "NewroomCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NewRoomCell")
        collectionView.register(UINib(nibName: "TopmenuCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CustomCell")
    }
    
    //     アカウントアイコンがタップされたときに実行されるメソッド
    @IBAction func accountButtonTapped() {
        
        performSegue(withIdentifier: "toAccountDetail", sender: nil)
    }
    
    var delegate: TopmenuViewController? = nil
    
    override func viewDidLayoutSubviews() {
        
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33),
                                          heightDimension: .fractionalHeight(0.8))
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        item.contentInsets = NSDirectionalEdgeInsets(top: 25, leading: 25, bottom: 25, trailing: 25)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.8))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.orthogonalScrollingBehavior = .groupPaging
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        
        let layout = UICollectionViewCompositionalLayout(section: section, configuration: config)
        
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
    }
    
    //画面が表示されるたびに呼び出される
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // ここで自分が作ったroomをすべてFirebaseから取得しています
        getRooms() {
            self.rooms.sort(by: { $0.time <= $1.time})
            self.collectionView.reloadData()
        }
    }
    
    let storage = Storage.storage()
    
    @IBAction func toNewRoomView() {
        performSegue(withIdentifier: "toNewRoomView", sender: nil)
    }
    
    // roomsにfirestoreに保存してある部屋データを全部入れる
    func getRooms(completion: @escaping () -> Void) {
        
        // 用意してある変数を初期化
        rooms = []
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("rooms").whereField("uid", isEqualTo: uid).getDocuments() { (snaps, error) in
            if let error {
                
                print(error.localizedDescription)
                
                return
            }
            guard let documents = snaps?.documents else { return }
            
            for document in documents {
                do {
                    let uploadRoomData = try document.data(as: UploadRoomData.self)
                    // firestoreからとってきたデータの中に画像の保存先URLがあるから、それをもとに画像データをStorageから引っ張ってくる
                    self.getImage(imageURL: uploadRoomData.imageURL) { imageData in
                        let roomData = RoomData(uploadRoomData: uploadRoomData, id: document.documentID, imageData: imageData)
                        self.rooms.append(roomData)
                        completion()
                    }
                    
                }
                catch {
                    print(error)
                }
            }
        }
    }
    
    //画像デー タを引っ張ってくる関数
    func getImage(imageURL: String, completion: @escaping (Data) -> Void) {
        if let url = URL(string: imageURL) {
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                // Error handling...
                guard let imageData = data else { return }
                
                DispatchQueue.main.async {
                    completion(imageData)
                }
            }.resume()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "godetail" {
            
            let mainroomViewController = segue.destination as! MainroomViewController
            mainroomViewController.mainroom = selectedroom
        }
    }
    
    //セクションの中のセルの数を返す
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rooms.count + 1
    }
    
    // スライドした時、次に何番目のセルが出てくるのか
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print(indexPath.row)
        
        if indexPath.row == 0 { return }
        let camera = GMSCameraPosition.camera(
            withLatitude: CLLocationDegrees(rooms[indexPath.row - 1].markers.last?.latitude ?? 0),
            longitude: CLLocationDegrees(rooms[indexPath.row - 1].markers.last?.longitude ?? 0),
            zoom: 15.0)
        
        mapView.camera = camera
    }
    
    //セルに表示する内容を記載する
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //indexPath.row : 何番目のセルか
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewRoomCell", for: indexPath as IndexPath) as! NewroomCollectionViewCell
            
            return cell
        }else {
            //storyboard上のセルを,,生成　storyboardのIdentifierで付けたものをここで設定する
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCell", for: indexPath as IndexPath) as! TopmenuCollectionViewCell
            
            cell.setupCell(mainTitle: rooms[indexPath.row - 1].title,
                           mainDate: rooms[indexPath.row - 1].time,
                           mainImageData: rooms[indexPath.row - 1].imageData)
            
            return cell
        }
    }
    
    //(セル選択時の処理)
    internal func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("\(indexPath.row)番目の行が選択されました。")
        
        //indexPath.row : 何番目のセルか
        if indexPath.row == 0 {
            //指定の遷移先に遷移する（最低限の処理）
            performSegue(withIdentifier: "newroom", sender: indexPath.row)
            
        }else {
            UserDefaults.standard.set(rooms[indexPath.row - 1].id, forKey: "currentRoomID")
            selectedroom = rooms[indexPath.row - 1]
            //指定の遷移先に遷移する（最低限の処理）
            performSegue(withIdentifier: "godetail", sender: indexPath.row)
        }
    }
}
