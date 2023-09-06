//
//  NewroomViewController.swift
//  PinPal
//
//  Created by 滑川裕里瑛 on 2023/09/03.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import FirebaseAuth

class NewroomViewController: UIViewController,UITextViewDelegate, UITextFieldDelegate {
    
    let storage = Storage.storage()
    
    var rooms = [RoomData]()
    
    @IBOutlet var openAlbumButton: UIButton!
    @IBOutlet var roomImageView: UIImageView!
    @IBOutlet var cameraActivationButtonAction: UIButton!
    @IBOutlet var roomTextField: UITextField!
    @IBOutlet var memoTextField: UITextField!
    @IBOutlet var timeDatePicker: UIDatePicker!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var roomLabel: UILabel!
    @IBOutlet var memoLabel: UILabel!
    @IBOutlet var imageLabel: UILabel!
    @IBOutlet var navigationBar: UINavigationBar!
    
    @IBOutlet var customimageButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roomTextField.delegate = self
        memoTextField.delegate = self
        
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    
    
    
    
    @IBAction func openAlbum() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            
            present(picker, animated: true, completion: nil)
        }
        
        
    }
    
    
    
    @IBAction func didTouchDowncameraActivationButton() {
        UIView.animate(withDuration: 0.2, animations: {
            self.cameraActivationButtonAction.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        })
    }
    
    @IBAction func didTouchDragExitcameraActivationButton() {
        UIView.animate(withDuration: 0.2, animations: {
            self.cameraActivationButtonAction.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    @IBAction func didTouchUpInsidecameraActivationButton() {
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.3,
                       initialSpringVelocity: 8,
                       options: .curveEaseOut,
                       animations: { () -> Void in
            
            self.cameraActivationButtonAction.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: nil)
        
    }
    
    @IBAction func didTouchDownopenAlbumButton() {
        UIView.animate(withDuration: 0.2, animations: {
            self.openAlbumButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        })
    }
    
    @IBAction func didTouchDragExitopenAlbumButton() {
        UIView.animate(withDuration: 0.2, animations: {
            self.openAlbumButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    @IBAction func didTouchUpInsideopenAlbumButton() {
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.3,
                       initialSpringVelocity: 8,
                       options: .curveEaseOut,
                       animations: { () -> Void in
            
            self.openAlbumButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: nil)
        
    }
    
    @IBAction func cancel() {
        dismiss(animated: true)
        
    }
    
    
    @IBAction func save () {
        // ここで部屋データをfirebaseに載せています
        uploadImage() { url in
            self.createRoom(imageURL: url) {
                // 全データをFirebaseに移し終わったら、前の画面に戻る。
                self.dismiss(animated: true)
            }
        }
    }
    
    // Storageに画像を載せる関数
    func uploadImage(completion: @escaping (String) -> Void) {
        // 画像をアップロードするためのランダムなファイル名を生成
        let imageFileName = UUID().uuidString
        
        // Firebase Storageへの参照を作成
        let storageRef = storage.reference().child(imageFileName)
        
        let image = roomImageView.image ?? UIImage(named: "noimage")!
        
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            
            
            // 画像をFirebase Storageにアップロード
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("画像のアップロードに失敗しました: \(error)")
                    return
                }
                
                // アップロードが成功したら、画像のダウンロードURLを取得
                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        print("ダウンロードURLの取得に失敗しました: \(error)")
                        return
                    }
                    
                    if let downloadURL = url {
                        // Firestoreに画像のURLを保存
                        completion(downloadURL.absoluteString)
                    }
                }
            }
        }
    }
    
    // Firestoreにデータを載せる関数
    func createRoom(imageURL: String ,completion: @escaping () -> Void) {
        
        // firestoreに載せるデータを生成している。firestoreに持ってくからUploadRoomData。
        // uidのところはAuth.auth().currentUser!.uid　になる。
        // titleなども、新規作成で入力されたデータを入れる。
        let uploadRoomData = UploadRoomData(
            uid: Auth.auth().currentUser!.uid,
            title: roomTextField.text!,
            expirationDate: Date(),
            time: Date(),
            memo: memoTextField.text!,
            imageURL: imageURL,
            markers: []
        )
        
        do {
            // Firestoreにデータを載せる。
            try Firestore.firestore().collection("rooms").document().setData(from: uploadRoomData) { _ in
                
                completion()
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
}

extension NewroomViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBAction func cameraActivationButtonAction(_ sender: Any?) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ imagepicker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[.originalImage] as? UIImage {roomImageView.image = pickedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView:UITableView, CanEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
