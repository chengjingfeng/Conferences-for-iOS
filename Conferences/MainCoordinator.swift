//
//  MainCoordinator.swift
//  Conferences
//
//  Created by Zagahr on 26/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

final class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    enum Tab: Int {
        case home
        case conferences
        case watchlist

        var coordinator: Coordinator {
            switch self {
            case .home:
                return HomeCoordinator()
            case .conferences:
                return ConferencesCoordinator()
            case .watchlist:
                return ConferencesCoordinator(type: .watchlist)
            }
        }
    }

    let home = Tab.home.coordinator
    let conferences = Tab.conferences.coordinator
    let watchlist = Tab.watchlist.coordinator

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.tintColor = .primaryText
        tabBar.barTintColor = .elementBackground
        viewControllers = [home.vc, conferences.vc, watchlist.vc]

        APIClient.shared.fetchConferences()
    }

    func handle(_ launchOption: [UIApplication.LaunchOptionsKey: Any]?) {
        // handle shourt cut items
    }

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let index = tabBar.items?.firstIndex(of: item) else { return }

        notifyCoordinator(at: index)
    }

    func notifyCoordinator(at index: Int) {
        switch index {
        case Tab.home.rawValue:
            home.coordinatorWillAppear()
        case Tab.conferences.rawValue:
            conferences.coordinatorWillAppear()
        case Tab.watchlist.rawValue:
            watchlist.coordinatorWillAppear()
        default:
            break
        }
    }
}
