//
//  AppDelegate.swift
//  TickTockClone
//
//  Created by いっちゃん on 2023/08/23.
//

import UIKit
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    //SighUpの時の戻るボタン
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UINavigationBar.appearance().tintColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 1)
        let backing = UIImage(named: "chevren.backward")
        UINavigationBar.appearance().backIndicatorImage = backing
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backing
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(.init(horizontal: -1000, vertical: 0), for: .default)
        FirebaseApp.configure()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

