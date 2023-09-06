//
//  UpdateAccountViewController.swift
//  PinPal
//
//  Created by 滑川裕里瑛 on 2023/09/03.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol CatchProtocol {
    
    func catchData(newAccountName: String)
    
}

class UpdateAccountViewController: UIViewController {
    
    //プロトコルを変数化する
    var delegate:CatchProtocol?
    
    @IBOutlet var accountField: UITextField!
    @IBOutlet var updateButton: UIButton!
    var userManager = UserManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addStyle(to: updateButton)
        updateButton.layer.cornerRadius = 5
        AccountDisplay()
        
        
        
    }
    
    @IBAction func accountUpdateButtonTapped(_ sender: UIButton){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if let accountTitle = accountField.text, !accountTitle.isEmpty {
            userManager.updateAccount(displayName: accountField.text!, userID: uid)
            
            //元の画面に書いたcatchDataメソッドが呼ばれる、passedCounterの中身を受け渡す
            delegate?.catchData(newAccountName: accountTitle)
            
            //元の画面に戻る処理
            dismiss(animated: true, completion: nil)
            
            //1つ前の画面
            let settingView = self.presentingViewController as! SettingViewController
            settingView.AccountDisplay()
            
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func AccountDisplay() {
        
        guard let user = Auth.auth().currentUser else { return }
        
        self.userManager.getUserDisplayName { displayName in
            DispatchQueue.main.async {
                self.accountField.text = displayName
            }
        }
    }
    
    @IBAction func didTouchDownupdateButton() {
        UIView.animate(withDuration: 0.2, animations: {
            self.updateButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        })
    }
    
    @IBAction func didTouchDragupdateButton() {
        UIView.animate(withDuration: 0.2, animations: {
            self.updateButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
    
    @IBAction func didTouchUpInsideupdateButton() {
        UIView.animate(withDuration: 0.5,
                       delay: 0.0,
                       usingSpringWithDamping: 0.3,
                       initialSpringVelocity: 8,
                       options: .curveEaseOut,
                       animations: { () -> Void in
            
            self.updateButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }, completion: nil)
    }
    
    //     updateButtonをタップしたときに振動
    @IBAction func updateButtontap() {
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.impactOccurred()
    }
    
    //影のスタイル
    func addStyle(to button: UIButton!){
        //影の濃さ
        button.layer.shadowOpacity = 0.1
        //ぼかしの大きさ
        button.layer.shadowRadius = 3
        //いろ
        button.layer.shadowColor = UIColor.black.cgColor
        //影の方向
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
    }
    
    //他の場所タップするとキーボードが閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
