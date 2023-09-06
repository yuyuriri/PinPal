//
//  AppDelegate.swift
//  PinPal
//
//  Created by 滑川裕里瑛 on 2023/09/03.
//

import UIKit
import GoogleMaps
import GooglePlaces
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        GMSPlacesClient.provideAPIKey("AIzaSyD9f2_8Y-_VxIVuQd-L4sNhT-0swGg7SUM")
        GMSServices.provideAPIKey("AIzaSyD9f2_8Y-_VxIVuQd-L4sNhT-0swGg7SUM")
        
        GooglePlacesManager.shared.setUp()
        
        FirebaseApp.configure()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        
        return GIDSignIn.sharedInstance.handle(url)
    }
}
