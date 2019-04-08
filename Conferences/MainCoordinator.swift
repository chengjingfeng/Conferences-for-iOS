//
//  MainCoordinator.swift
//  Conferences
//
//  Created by Zagahr on 26/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit


final class MainCoordinator {
    let tabBarController: UITabBarController

    private lazy var settingsScene: SettingsCoordinator = {
        let coordinator = SettingsCoordinator()
        coordinator.start()

        return coordinator
    }()


    init() {
        self.tabBarController = UITabBarController()
    }

    func start() {
        self.tabBarController.tabBar.tintColor = .primaryText
        self.tabBarController.tabBar.barTintColor = .elementBackground
        self.tabBarController.setViewControllers([SplitViewController(), settingsScene.rootViewController], animated: false)
    }

}
