//
//  ConferencesCoordinator.swift
//  Conferences
//
//  Created by Zagahr on 26/04/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

enum PresentationType: String {
    case all
    case watchlist = "realm_watchlist"

    var title: String {
        switch self {
        case .all:
            return "Search"
        case .watchlist:
            return "Watchlist"
        }
    }

    var isSearchEnabled: Bool {
        switch self {
        case .all:
            return true
        default:
            return false
        }
    }
}

final class ConferencesCoordinator: Coordinator, APIStatus {
    private var presentationType: PresentationType

    init(type: PresentationType = .all) {
        self.presentationType = type

        registerForStatusChange()
    }

    lazy var vc: UIViewController = {
        let vc = SplitViewController(type: presentationType)
        vc.tabBarItem = tabBarItem
        vc.coordinator = self

        return vc
    }()

    lazy var tabBarItem: UITabBarItem = {
        switch presentationType {
        case .all:
            return UITabBarItem(title: "Search", image: UIImage(named: "search"), selectedImage: nil)
        case .watchlist:
            return UITabBarItem(title: "Watchlist", image: UIImage(named: "watchlist_filled"), selectedImage: nil)
        }
    }()

    private lazy var talkService: TalkService = {
        let service = TalkService()
        service.delegate = self

        return service
    }()

    func coordinatorWillAppear() {
        if presentationType == .watchlist {
            start()
        }
    }

    func start() {
        talkService.fetchData(type: presentationType)
    }

    func filter(by searchTerm: String = "") {
        talkService.filterTalks(by: searchTerm)
    }
}

extension ConferencesCoordinator: TalkServiceDelegate {
    func didFetch(_ conferences: [ConferenceModel]) {
        (vc as? SplitViewController)?.set(conferences)
    }

    func fetchFailed(with error: APIError) {
        print(error)
    }
}
