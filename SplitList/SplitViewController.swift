//
//  SplitViewController.swift
//  Conferences
//
//  Created by Zagahr on 26/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

typealias TalkItem = (talk: TalkModel, indexPath: IndexPath)

final class SplitViewController: UISplitViewController {
    weak var coordinator: ConferencesCoordinator?
    private var type: PresentationType

    private let detailViewController = DetailViewController()
    private lazy var tagListView: TagListView = {
        let view = TagListView()

        view.selectionHandler = { [weak self] (tag) in
            guard let self = self else { return }
            self.coordinator?.filter()
        }

        return view
    }()

    private lazy var listViewController: ConferneceListController = {
        let vc = ConferneceListController(style: .grouped)
        vc.title = type.title

        if type.isSearchEnabled {
            vc.navigationItem.searchController = searchController
            vc.navigationItem.hidesSearchBarWhenScrolling = false
        }

        vc.selectionHandler = { [weak self] (talkItem) in
            guard let self = self else { return }

            self.detailViewController.configureView(with: talk)

            self.showDetailViewController(self.detailViewController, sender: nil)
        }

        return vc
    }()

    private lazy var searchController: UISearchController = {
        let vc = UISearchController(searchResultsController: nil)
        vc.searchBar.barStyle = .blackTranslucent
        vc.searchBar.autocapitalizationType = .none
        vc.searchResultsUpdater = self
        vc.searchBar.inputAccessoryView = tagListView
        vc.searchBar.keyboardAppearance = .dark
        vc.obscuresBackgroundDuringPresentation = false

        return vc
    }()

    private lazy var listViewControllerNavigation: UINavigationController = {
        let navigationController = UINavigationController(rootViewController: listViewController)
        navigationController.navigationBar.barTintColor = UIColor.panelBackground
        navigationController.navigationBar.setValue(true, forKey: "hidesShadow")
        navigationController.navigationBar.tintColor = UIColor.white
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]

        return navigationController
    }()

    init(type: PresentationType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)

        self.viewControllers = [listViewControllerNavigation, detailViewController]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    private func configureView() {
        self.delegate = self
        self.minimumPrimaryColumnWidth = 380
        self.maximumPrimaryColumnWidth = 400
        self.view.backgroundColor = .elementBackground
        self.preferredDisplayMode = .allVisible
    }

    func set(_ conferences: [ConferenceModel]) {
        listViewController.items = conferences

        switch type {
        case .watchlist:
            if conferences.isEmpty {
                listViewController.showEmtpyWatchlist()
            }
        default:
            print("")
        }

        if let firstTalk = conferences.first?.talks.first {
            detailViewController.configureView(with: firstTalk)
        }
    }
    
}

extension SplitViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}

extension SplitViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        coordinator?.filter(by: text)
    }
}
