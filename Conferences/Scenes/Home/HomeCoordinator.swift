//
//  HomeCoordinator.swift
//  Conferences
//
//  Created by Zagahr on 27/04/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit


final class HomeCoordinator: Coordinator {
    private var presentationType: PresentationType

    init(type: PresentationType = .all) {
        self.presentationType = type
    }

    lazy var vc: UIViewController = {
        let vc = UIViewController()
        vc.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "home"), selectedImage: nil)

        return vc
    }()

    func coordinatorWillAppear() {
        
    }

    func start() {
    }
}
