//
//  AppDelegate.swift
//  Conferences
//
//  Created by Zagahr on 23/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit
import TinyConstraints
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    var tabBarController: MainTabBarController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        StyleGuide().setup()

        window?.rootViewController = LoadingViewController(delegate: self)

        return true
    }
}

extension AppDelegate: LoadingDelegate {
    func didFinish() {
        window?.switchRootViewController(to: MainTabBarController(), animated: true, duration: 0.75, options: .transitionCrossDissolve, nil)
    }
}
