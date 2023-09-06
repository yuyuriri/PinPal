//
//  MainroomViewController.swift
//  PinPal
//
//  Created by 滑川裕里瑛 on 2023/09/03.
//

import UIKit
import GoogleMaps
import GooglePlaces
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth

// Firestoreで、何番目のマーカーを変更すればいいかわかるように、indexを追加。
class CustomMarker: GMSMarker {
    var index: Int = 0
    init(index: Int) {
        self.index = index
    }
}


class MainroomViewController: UIViewController, GMSMapViewDelegate, UISearchResultsUpdating {
    
    let db = Firestore.firestore()
    var mapView: GMSMapView!
    var tappedMarker : GMSMarker?
    var customInfoWindow : CustomInfoWindow?
    var editingMarker: GMSMarker?
    var markerTextField: UITextField!
    var contentTextView: UITextView!
    var markers: [CustomMarker] = [] // ピンを管理するための配列
    
    // 現在地の座標を格納する変数
    private var current: CLLocationCoordinate2D?
    
    // Locationの取得に必要なManager
    private lazy var locationManager: CLLocationManager = {
        let manager = CLLocationManager()
        // ViewControllerでCLLocationManagerDelegateのメソッドを利用できるように
        manager.delegate = self
        return manager
        
    }()
    
    let searchVC = UISearchController(searchResultsController: ResultViewController())
    
    @IBOutlet var returnButton: UIButton!
    
    var mainroom: RoomData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Maps"
        
        navigationController?.navigationBar.backgroundColor = .clear
        searchVC.searchBar.backgroundColor = .clear
        searchVC.searchBar.searchTextField.backgroundColor = .white
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
        
        // Locationを取得開始する
        locationManager.startUpdatingLocation()
        
        // MARK: 後でやる
        let camera = GMSCameraPosition.camera(
            withLatitude: -33.86,
            longitude: 151.20,
            zoom: 15.0)
        
        mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        self.view.addSubview(mapView)
        
        //右下のボタンを追加
        mapView.settings.myLocationButton = true
        
        //現在地表示
        mapView.isMyLocationEnabled = true
        
        //Creates a marker in the center of the map
        let marker = GMSMarker()
        
        //マーカーのアイコンをイメージにする
        marker.icon = self.imageWithImage(image: UIImage(named: "pinimage")!, scaledToSize: CGSize(width: 40.0, height: 40.0))
        
        marker.tracksViewChanges = true
        marker.map = mapView
        
        self.tappedMarker = GMSMarker()
        self.customInfoWindow = CustomInfoWindow().loadView()
        self.mapView.delegate = self
        
        view.addSubview(mapView)
        view.sendSubviewToBack(mapView)
        view.addSubview(mapView)
        
        showMarkers()
        
        observeRoom()
    }
    
    func imageWithImage(image: UIImage, scaledToSize newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    // ピンがタップされた時
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        NSLog("marker was tapped")
        
        // markersの中で、markerと緯度経度が同じCustomMarkerを探す。
        guard let customMarker = markers.first(where: { $0.position.latitude == marker.position.latitude && $0.position.longitude == marker.position.longitude }) else { return false }
        
        editingMarker = marker
        
        tappedMarker = marker
        
        // タップされたピンのところにカメラを動かす
        let position = marker.position
        mapView.animate(toLocation: position)
        let point = mapView.projection.point(for: position)
        let newPoint = mapView.projection.coordinate(for: point)
        let camera = GMSCameraUpdate.setTarget(newPoint)
        mapView.animate(with: camera)
        
        // InfoWindowを追加
        let opaqueWhite = UIColor(white: 1, alpha: 0.85)
        customInfoWindow?.layer.backgroundColor = opaqueWhite.cgColor
        customInfoWindow?.layer.cornerRadius = 8
        customInfoWindow?.center = mapView.projection.point(for: position)
        customInfoWindow?.contentTextView.text = marker.title ?? ""
        customInfoWindow?.marker = customMarker
        mapView.addSubview(customInfoWindow!)
        
        return false
        
    }
    
    // Firestoreを監視する（変更があったら、これを呼び出す）
    func observeRoom() {
        // 部屋のIDを取得
        guard let roomID = UserDefaults.standard.string(forKey: "currentRoomID") else {
            return
            
        }
        
        // Firestoreの変化があったら、この中身が呼び出される
        db.collection("rooms").document(roomID).addSnapshotListener { documentSnapshot, error in
            
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
                
            }
            
            do {
                // Firestoreの部屋ドキュメントの中から、markersを取り出す。
                let uploadRoomData = try document.data(as: UploadRoomData.self)
                
                self.mainroom.markers = uploadRoomData.markers
                
                self.showMarkers()
            } catch {
                print(error)
            }
        }
    }
    
    // 保存されているマーカーを全部表示する
    func showMarkers() {
        
        // 今表示されてる全部のマップを消す
        for marker in markers {
            // マップからマーカーを削除する
            marker.map = nil
        }
        
        markers = []
        
        for i in 0..<mainroom.markers.count {
            
            // 新しいマーカーを生成。
            let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: mainroom.markers[i].latitude, longitude: mainroom.markers[i].longitude))
            marker.title = mainroom.markers[i].title
            
            // markers配列用にCustomMarkerを生成
            let customMarker = CustomMarker(index: i)
            customMarker.position = marker.position
            customMarker.title = marker.title
            customMarker.icon = imageWithImage(image: UIImage(named: "pinimage")!, scaledToSize: CGSize(width: 40.0, height: 40.0))
            markers.append(customMarker)
            
            customMarker.map = mapView
        }
        
        // markersの最後の要素を取ってくる
        if let marker = markers.last {
            // その位置にカメラを移動
            let position = marker.position
            mapView.animate(toLocation: position)
            let point = mapView.projection.point(for: position)
            let newPoint = mapView.projection.coordinate(for: point)
            let camera = GMSCameraUpdate.setTarget(newPoint)
            mapView.animate(with: camera)
        }
    }
    
    //    キーボード閉じる
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return self.customInfoWindow
    }
    
    // マップ上をタップ
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        // InfoWindowを隠す
        customInfoWindow?.removeFromSuperview()
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let position = tappedMarker?.position
        customInfoWindow?.center = mapView.projection.point(for: position!)
        customInfoWindow?.center.y -= 140
    }
    
    @IBAction func back() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              let resultsVC = searchController.searchResultsController as? ResultViewController else {
            return
        }
        
        print(query)
        resultsVC.delegate = self
        GooglePlacesManager.shared.findPlaces(query: query) { result in
            switch result {
            case .success(let places):
                
                DispatchQueue.main.async {
                    resultsVC.update(with: places)
                }
                
            case.failure(let error):
                print(error)
            }
        }
    }
}

extension MainroomViewController: ResultViewControllerDelegate {
    func didTapPlace(with coordinates: CLLocationCoordinate2D) {
        searchVC.searchBar.resignFirstResponder()
        searchVC.dismiss(animated: true)
        
        let camera = GMSCameraPosition.camera(
            withLatitude: coordinates.latitude,
            longitude: coordinates.longitude,
            zoom: 60.0)
        
        let marker = GMSMarker()
        
        marker.position = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
        
        //吹き出しのメインタイトル
        marker.title = "メインタイトル"

        //マーカーのアイコンをイメージにする
        marker.icon = self.imageWithImage(image: UIImage(named: "pinimage")!, scaledToSize: CGSize(width: 40.0, height: 40.0))
        
        marker.tracksViewChanges = true
        marker.map = mapView
        
        mapView.camera = camera
    }
}

extension MainroomViewController: CLLocationManagerDelegate {
    // マップを長押しするとはしる処理
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        // 長押しした地点の座標
        print(coordinate)
        // 新しいピンを追加する
        let newMarker = CustomMarker(index: markers.count)
        newMarker.position = coordinate
        newMarker.map = mapView
        newMarker.icon = imageWithImage(image: UIImage(named: "pinimage")!, scaledToSize: CGSize(width: 40.0, height: 40.0))
        
        markers.append(newMarker)
        
        // Firestoreのmarkersの更新
        guard let roomID = UserDefaults.standard.string(forKey: "currentRoomID") else { return }
        Firestore.firestore().collection("rooms").document(roomID).getDocument() { (snap, error) in
            
            do {
                guard var uploadRoomData = try snap?.data(as: UploadRoomData.self) else { return }
                
                let newMarker = Marker(title: "", latitude: Double(coordinate.latitude), longitude: Double(coordinate.longitude))
                
                uploadRoomData.markers.append(newMarker)
                
                try Firestore.firestore().collection("rooms").document(roomID).setData(from: uploadRoomData)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

