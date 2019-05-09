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
    case custom(String) //Paul Hudson, dotSwift 20

    var title: String {
        switch self {
        case .search:
            return "Search"
        case .watchlist:
            return "Watchlist"
        case .custom(let title):
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

final class ConferencesCoordinator: Coordinator {
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
        case .custom:
            print("return nothing")
            return UITabBarItem(title: "", image: nil, selectedImage: nil)
        }

    }()

    private lazy var talkService: TalkService = {
        let service = TalkService()
        service.delegate = self

        return service
    }()

    func start() {
        talkService.fetchData(type: presentationType)
    }

    func filter(by searchTerm: String = "") {
        talkService.filterTalks(by: searchTerm)
        //(vc as? SplitViewController)?.tagListView.updateSuggestions(to: talkService.getSuggestions(basedOn: searchTerm))
        //(vc as? SplitViewController)?.tagListView.showSuggestionsTable()
    }
}

extension ConferencesCoordinator: TalkServiceDelegate {
    func didFetch(_ conferences: [ConferenceViewModel]) {
        (vc as? SplitViewController)?.set(conferences)
    }

    func fetchFailed(with error: APIError) {
        print(error)
    }
}
