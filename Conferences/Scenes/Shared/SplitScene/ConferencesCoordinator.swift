//
//  ConferencesCoordinator.swift
//  Conferences
//
//  Created by Zagahr on 26/04/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

enum PresentationType {
    case search
    case watchlist
    case filter(String)
    case custom(String, [ListRepresentable])

    var title: String {
        switch self {
        case .search:
            return "Search"
        case .watchlist:
            return "Watchlist"
        case .filter(let title):
            return title
        case .custom(let title, _):
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
        case .custom(_, let items):
            (vc as? SplitViewController)?.set(items)
        default:
            talkService.fetchData(type: presentationType)
        }
    }

    func filter(by searchTerm: String = "") {
        talkService.filterTalks(by: searchTerm)
        //(vc as? SplitViewController)?.tagListView.updateSuggestions(to: talkService.getSuggestions(basedOn: searchTerm))
        //(vc as? SplitViewController)?.tagListView.showSuggestionsTable()
    }
}

extension SplitCoordinator: TalkServiceDelegate {
    func didFetch(_ conferences: [ConferenceModel]) {
        (vc as? SplitViewController)?.set(conferences)
    }

    func fetchFailed(with error: APIError) {
        print(error)
    }
}
