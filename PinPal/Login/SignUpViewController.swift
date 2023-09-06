//
//  SignUpViewController.swift
//  PinPal
//
//  Created by 滑川裕里瑛 on 2023/09/03.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

class SignUpViewController: UIViewController {

    @IBOutlet var nameTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func registerButtonTapped() {
        // ユーザーが入力した名前を取得
        if let name = nameTextField.text, !name.isEmpty {
            // 入力した名前を使用して、Userオブジェクトを作成
            let user = User(displayName: name, createdTime: Date(), uid: Auth.auth().currentUser!.uid)
            
            // Firestoreのコレクションにアクセス
            let db = Firestore.firestore()
            
            // UserDataStoreクラスのcreateUser関数を呼び出し、Firestoreに新しいユーザーを追加
            UserDataStore.createUser(user: user) { (success) in
                if success {
//
//                    // ホーム画面に遷移
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TopmenuViewController") as UIViewController
                    let sceneDelegate = UIApplication.shared.connectedScenes.first!.delegate as! SceneDelegate
                    sceneDelegate.window!.rootViewController = vc
                } else {
                    print("Failed to create user")
                }
            }
        }
    }
    
    //他の場所タップするとキーボードが閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}
