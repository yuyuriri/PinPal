//
//  SettingViewController.swift
//  PinPal
//
//  Created by 滑川裕里瑛 on 2023/09/03.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class SettingViewController: UIViewController, CatchProtocol {
    
    func catchData(newAccountName: String) {
        accountName.text = newAccountName
    }

    @IBOutlet var signOutButton: UIButton!
    @IBOutlet var accountImage: UIImageView!
    @IBOutlet var accountName: UILabel!
    @IBOutlet var updateButton: UIButton!
    @IBOutlet var deleteButton: UIButton!
    
    var userManager = UserManager()
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //アカウント名と画像を表示
        AccountDisplay()
        
        accountImage.layer.cornerRadius = accountImage.frame.size.width / 2
        accountImage.clipsToBounds = true
        
        signOutButton.layer.cornerRadius = 10
        signOutButton.layer.shadowColor = UIColor.gray.cgColor
        signOutButton.layer.shadowOpacity = 0.1
        signOutButton.layer.shadowOffset = CGSize(width: 5, height: 5)
        signOutButton.layer.shadowRadius = 3
        
        deleteButton.layer.cornerRadius = 10
        deleteButton.layer.shadowColor = UIColor.gray.cgColor
        deleteButton.layer.shadowOpacity = 0.1
        deleteButton.layer.shadowOffset = CGSize(width: 5, height: 5)
        deleteButton.layer.shadowRadius = 3
        // Firebase Authenticationでログインしているかどうかを確認する
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        // Googleアカウントのプロフィール画像のURLを取得する
        guard let photoURL = user.photoURL else {
            return
        }
        
        // Googleアカウントのプロフィール画像をダウンロードして、accountImageに表示する
        URLSession.shared.dataTask(with: photoURL) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            if let data = data {
                DispatchQueue.main.async {
                    let image = UIImage(data: data)
                    self.accountImage.image = image
                }
            }
        }.resume()
        
        // Firestoreのコレクションにアクセス
        let db = Firestore.firestore()
        
        // ログインしているユーザーのUIDを取得
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        db.collection("users")
            .whereField("uid", isEqualTo: Auth.auth().currentUser!.uid)
            .getDocuments { snapshot, error in
                
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    print(snapshot!.documents)
                    for document in snapshot!.documents {
                        let data = document.data()
                        let userName = data["display_name"] as? String ?? "user"
                        self.accountName.text = userName
                    }
                }
            }
    }

    @IBAction func signOutButtonTapped(_ sender: Any) {
        
        //アラートを表示する
        let alert = UIAlertController(title: "サインアウト", message: "サインアウトしますか？", preferredStyle: .alert)
        let signOutAction = UIAlertAction(title: "サインアウト", style: .default) { _ in
            self.signOut()
        }
        signOutAction.setValue(UIColor.red, forKey: "titleTextColor")
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(cancelAction)
        alert.addAction(signOutAction)
        present(alert, animated: true)
    }
    
    @IBAction func UpdateButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "ToUpdateViewController", sender: nil)
    }
    
    func AccountDisplay() {
        accountImage.layer.cornerRadius = accountImage.frame.size.width / 2
        accountImage.clipsToBounds = true
        
        guard let user = Auth.auth().currentUser else { return }
        guard let photoURL = user.photoURL else { return }
        
        URLSession.shared.dataTask(with: photoURL) { (data, response, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            if let data = data {
                DispatchQueue.main.async {
                    let image = UIImage(data: data)
                    self.accountImage.image = image
                }
            }
        }.resume()
    }
    
    //影のスタイル
    func addStyle(to button: UIButton!){
        //影の濃さ
        button.layer.shadowOpacity = 0.1
        //ぼかしの大きさ
        button.layer.shadowRadius = 5
        //いろ
        button.layer.shadowColor = UIColor.black.cgColor
        //影の方向
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
    }
    
    
    @objc func signOut() {
        do {
            try Auth.auth().signOut()
            // サインアウトが成功した場合の処理
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
            let alert = UIAlertController(title: "エラー", message: "サインアウトが失敗しました。しばらくしてから再度お試しください。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @objc func deleteAccount() {
        let db = Firestore.firestore()
            db.collection("users").document(Auth.auth().currentUser!.uid).delete { error in
                if let error = error {
                    print("Error removing document: \(error)")
                } else {
                    print("Document successfully removed!")
                    // 一覧画面に戻る
//                    self.navigationController?.popViewController(animated: true)
                }
            }
        db.collection("events")
            .whereField("userID", isEqualTo: Auth.auth().currentUser?.uid)
            .getDocuments { (snapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                    return
                }
                
                for document in snapshot!.documents {
                    document.reference.delete()
                    print("events Document successfully removed!")
                }
            }
    }
    
    @IBAction func deleteAccountButtonTapped(){
        let alert = UIAlertController(title: "アカウントを削除しますか？", message: "アカウントを削除すると保存した内容も削除されます。", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "削除", style: .default) { _ in
            self.deleteAccount()
            self.signOut()
        }
        deleteAction.setValue(UIColor.red, forKey: "titleTextColor")
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { _ in
                self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true)
    }
    
    @IBAction func didTouchDowndeleteButton() {
        UIView.animate(withDuration: 0.2, animations: {
            self.deleteButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        })
    }
    
    @IBAction func didTouchDragdeleteButton() {
        UIView.animate(withDuration: 0.2, animations: {
            self.deleteButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    @IBAction func didTouchUpInsidedeleteButton() {
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.3,
                       initialSpringVelocity: 8,
                       options: .curveEaseOut,
                       animations: { () -> Void in
            
            self.deleteButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: nil)
    }
    
    //     deleteButtonをタップしたときに振動
    @IBAction func deleteButtontap() {
        UINotificationFeedbackGenerator().notificationOccurred(.warning)
    }
    
    @IBAction func didTouchDownsignOutButton() {
        UIView.animate(withDuration: 0.2, animations: {
            self.signOutButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        })
    }
    
    @IBAction func didTouchDragsignOutButton() {
        UIView.animate(withDuration: 0.2, animations: {
            self.signOutButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    @IBAction func didTouchUpInsidesignOutButton() {
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.3,
                       initialSpringVelocity: 8,
                       options: .curveEaseOut,
                       animations: { () -> Void in
            
            self.signOutButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: nil)
    }
    
    //     signOutButtonをタップしたときに振動
    @IBAction func signOutButtontap() {
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let updateView = segue.destination as! UpdateAccountViewController
        updateView.delegate = self
    }
    

}
