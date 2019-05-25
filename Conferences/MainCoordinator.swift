//
//  MainCoordinator.swift
//  Conferences
//
//  Created by Zagahr on 26/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

final class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    private var themedStatusBarStyle: UIStatusBarStyle?

    enum Tab: Int {
        case home
        case conferences
        case watchlist

        var coordinator: Coordinator {
            switch self {
            case .home:
                return HomeCoordinator()
            case .conferences:
                return SplitCoordinator()
            case .watchlist:
                return SplitCoordinator(type: .watchlist)
            }
        }
    }

    let home = Tab.home.coordinator
    let conferences = Tab.conferences.coordinator
    let watchlist = Tab.watchlist.coordinator

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return themedStatusBarStyle ?? super.preferredStatusBarStyle
    }


    override var childForStatusBarStyle: UIViewController? {
        return nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTheming()
        viewControllers = [home.vc, conferences.vc, watchlist.vc]

        home.start()
    }
}

extension MainTabBarController: Themed {
    func applyTheme(_ theme: AppTheme) {
        themedStatusBarStyle = theme.statusBarStyle
        setNeedsStatusBarAppearanceUpdate()

        tabBar.tintColor = theme.textColor
        tabBar.barTintColor = theme.secondaryBackgroundColor
    }
}
