//
//  SplitViewController.swift
//  Conferences
//
//  Created by Zagahr on 26/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit


final class SplitViewController: UISplitViewController {
    weak var coordinator: ConferencesCoordinator?
    private var type: PresentationType

    private lazy var detailViewController: DetailViewController = {
        let vc = DetailViewController()

        vc.wachlistAction = { [weak self] () in
            guard let self = self else { return }

            switch self.type {
            case .search:
                self.coordinator?.start()
            case .watchlist:
                self.listViewControllerNavigation.popToViewController(self.listViewController, animated: true)
                self.coordinator?.start()
            case .custom(_):
                print("todo")
            }
        }

        vc.watchedAction = { [weak self] () in
            guard let self = self else { return }

            self.coordinator?.start()
        }


        return vc
    }()

    lazy var tagListView: TagListView = {
        let view = TagListView()

        view.selectionHandler = { [weak self] (tag) in
            guard let self = self else { return }
            self.coordinator?.filter()
        }

        return view
    }()

    lazy var listViewController: ConferneceListController = {
        let vc = ConferneceListController(style: .grouped)
        vc.title = type.title

        if type.isSearchEnabled {
            vc.navigationItem.searchController = searchController
            vc.navigationItem.hidesSearchBarWhenScrolling = false
        }

        vc.selectionHandler = { [weak self] (talk, index) in
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        coordinator?.start()
    }

    private func configureView() {
        self.delegate = self
        self.minimumPrimaryColumnWidth = 380
        self.maximumPrimaryColumnWidth = 400
        self.view.backgroundColor = .elementBackground
        self.preferredDisplayMode = .allVisible
    }

    func set(_ conferences: [ConferenceViewModel]) {
        listViewController.dataInput = conferences

        if listViewController.tableView.indexPathForSelectedRow == nil {
            if let firstTalk = conferences.first?.talks.first {
                listViewController.tableView.selectRow(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: .none)
                detailViewController.configureView(with: firstTalk)
            } else {
                showEmptyList()
            }
        }
    }

    func showEmptyList() {
        UIView.animate(withDuration: 0.2) {
            self.detailViewController.navigationController?.navigationBar.barTintColor = .panelBackground
            self.detailViewController.blockingView.alpha = 1
        }

        switch type {
        case .watchlist:
            listViewController.showEmtpyWatchlist()
        case .search:
            print("no results for search found")
        case .custom(_):
            print("todo")
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
