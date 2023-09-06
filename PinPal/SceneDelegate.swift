//
//  SceneDelegate.swift
//  PinPal
//
//  Created by 滑川裕里瑛 on 2023/09/03.
//

import UIKit
import FirebaseAuth


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
                guard let scene = (scene as? UIWindowScene) else {
                    return
                }
                let window = UIWindow(windowScene: scene)
                self.window = window
                window.makeKeyAndVisible()

                let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "LoginView") as! LoginViewController
                window.rootViewController = vc
            } else {
                print(user?.uid)
                print(user?.email)
                print("ログイン済み")
            }
        }
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
