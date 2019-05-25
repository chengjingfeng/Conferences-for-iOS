//
//  ConferencesCoordinator.swift
//  Conferences
//
//  Created by Zagahr on 26/04/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

final class SplitCoordinator: Coordinator {
    private var presentationType: PresentationType

    init(type: PresentationType = .search) {
        self.presentationType = type
    }

    lazy var vc: UIViewController = {
        let vc = SplitViewController(type: presentationType)
        vc.tabBarItem = tabBarItem
        vc.coordinator = self

        return vc
    }()

    lazy var tabBarItem: UITabBarItem = {
        switch presentationType {
        case .search:
            return UITabBarItem(title: "Search", image: UIImage(named: "search"), selectedImage: nil)
        case .watchlist:
            return UITabBarItem(title: "Watchlist", image: UIImage(named: "watchlist_filled"), selectedImage: nil)
        default:
            return UITabBarItem(title: "", image: nil, selectedImage: nil)
        }
    }()

    func start() {
        switch presentationType {
        case .conference(_, let items, let header):
            (vc as? SplitViewController)?.set(items, header)
        case .speaker(_, let header):
            let items = TalkService.fetchData(type: presentationType)
            (vc as? SplitViewController)?.set(items, header)
        default:
            let items = TalkService.fetchData(type: presentationType)
            (vc as? SplitViewController)?.set(items)
        }
    }

    func filter(by searchTerm: String = "") {
        // TODO: Search
    }

    func present(inside navController: UINavigationController?) {
        if UIDevice.current.userInterfaceIdiom == .phone {
            presentForPhone(navController)
        } else {
            presentForPad(navController)
        }

        start()
    }

    private func presentForPhone(_ controller: UINavigationController?) {
        guard let splitVC = vc as? SplitViewController else { return }

        let list = splitVC.listViewController
        let detail = splitVC.detailViewController

        list.selectionHandler = { (talk, index) in
            detail.configureView(with: talk)
            controller?.pushViewController(detail, animated: true)
        }

        controller?.pushViewController(list, animated: true)
    }

    private func presentForPad(_ controller: UINavigationController?) {
        let container = UIViewController(nibName: nil, bundle: nil)
        container.addChild(vc)
        container.view.addSubview(vc.view)
        vc.view.edgesToSuperview()
        container.navigationItem.largeTitleDisplayMode = .never
        controller?.navigationBar.setValue(true, forKey: "hidesShadow")

        controller?.pushViewController(container, animated: true)
    }
}





















































































enum PresentationType {
    case search
    case watchlist
    case speaker(String, ListRepresentable)
    case conference(String, [ListRepresentable], ListRepresentable)

    var title: String {
        switch self {
        case .search:
            return "Search"
        case .watchlist:
            return "Watchlist"
        case .speaker(let title, _):
            return title
        case .conference(let title, _, _):
            return title
        }
    }

    var isSearchEnabled: Bool {
        switch self {
        case .search:
            return true
        default:
            return false
        }
    }

    var filter: String {
        switch self {
        case .watchlist:
            return "realm_watchlist"
        default:
            return ""
        }
    }
}
