//
//  AppDelegate.swift
//  Conferences
//
//  Created by Zagahr on 23/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit
import TinyConstraints

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?
    var tabBarController: MainTabBarController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window?.rootViewController = LoadingViewController(delegate: self)

        return true
    }
}

extension AppDelegate: LoadingDelegate {
    func didFinish() {
        window?.switchRootViewController(to: MainTabBarController(), animated: true, duration: 0.75, options: .transitionCrossDissolve, nil)
    }
}

public extension UIWindow {
    func switchRootViewController(
        to viewController: UIViewController,
        animated: Bool = true,
        duration: TimeInterval = 0.5,
        options: UIView.AnimationOptions = .transitionCrossDissolve,
        _ completion: (() -> Void)? = nil) {

        guard animated else {
            rootViewController = viewController
            completion?()
            return
        }

        UIView.transition(with: self, duration: duration, options: options, animations: {
            let oldState = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            self.rootViewController = viewController
            UIView.setAnimationsEnabled(oldState)
        }, completion: { _ in
            completion?()
        })
    }

}

