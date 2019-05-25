//
//  SplitViewController.swift
//  Conferences
//
//  Created by Zagahr on 26/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit


final class SplitViewController: UISplitViewController {
    weak var coordinator: SplitCoordinator?
    private var type: PresentationType

    lazy var detailViewController: DetailViewController = {
        let vc = DetailViewController()

        vc.wachlistAction = { [weak self] () in
            guard let self = self else { return }

            switch self.type {
            case .watchlist:
                self.listViewControllerNavigation.popToViewController(self.listViewController, animated: true)
                self.coordinator?.start()
            default:
                return
            }
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

    lazy var listViewController: ListViewController = {
        let vc = ListViewController(style: .grouped)
        vc.title = type.title
        
        if type.isSearchEnabled {
            vc.navigationItem.searchController = searchController
            vc.navigationItem.hidesSearchBarWhenScrolling = false
        }

        vc.selectionHandler = { [weak self] (talk, index) in
            guard let self = self else { return }

            self.detailViewController.configureView(with: talk)

            if UIDevice.current.userInterfaceIdiom == .pad {
                self.showDetailViewController(self.detailNavigationController, sender: nil)
            } else {
                self.showDetailViewController(self.detailViewController, sender: nil)
            }
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
        return UINavigationController(rootViewController: listViewController)
    }()

    private lazy var detailNavigationController: UINavigationController = {
        return UINavigationController(rootViewController: detailViewController)
    }()

    init(type: PresentationType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)

        if UIDevice.current.userInterfaceIdiom == .pad {
            self.viewControllers = [listViewControllerNavigation, detailNavigationController]
        } else {
            self.viewControllers = [listViewControllerNavigation, detailViewController]
        }

        configureView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)


        listViewControllerNavigation.navigationBar.prefersLargeTitles = navigationController == nil

        guard !listViewController.data.isEmpty else {
            coordinator?.start()

            return
        }

        if case PresentationType.watchlist = type {
            coordinator?.start()
        }
    }

    private func configureView() {
        let colorView = UIView()
        colorView.backgroundColor = .elementBackground
        view.insertSubview(colorView, at: 0)
        colorView.edgesToSuperview()

        self.delegate = self
        self.view.backgroundColor = .panelBackground
        self.minimumPrimaryColumnWidth = 380
        self.maximumPrimaryColumnWidth = 400
        self.preferredDisplayMode = .allVisible
    }

    func set(_ conferences: [ListRepresentable], _ header: ListRepresentable? = nil) {
        var selectedTalk: ListRepresentable?
        var selectedIndex: IndexPath?

        if let indexPath = listViewController.tableView.indexPathForSelectedRow {
            selectedTalk = listViewController.data[indexPath.section].children?[indexPath.row]
            selectedIndex = indexPath
        }
        
        listViewController.headerModel = header
        listViewController.data = conferences

        if let _ = header as? SpeakerModel {
            detailViewController.detailSummaryViewController.speakerView.isHidden = true
        }

        if conferences.isEmpty {
            showEmptyList()
        } else {
            guard UIDevice.current.userInterfaceIdiom == .pad else { return }

            if let selectedTalk = selectedTalk, let selectedIndex = selectedIndex {
                if conferences.indices.contains(selectedIndex.section) {
                    if conferences[selectedIndex.section].children?.indices.contains(selectedIndex.row) ?? false {
                        let newTalk = conferences[selectedIndex.section].children?[selectedIndex.row]

                        if selectedTalk.title == newTalk?.title {
                            listViewController.tableView.selectRow(at: selectedIndex, animated: false, scrollPosition: .none)

                            return
                        }
                    }

                }
            }


            if let talk = conferences.first?.children?.first as? TalkModel {
                listViewController.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
                detailViewController.configureView(with: talk)
            }
        }
    }

    func showEmptyList() {
        UIView.animate(withDuration: 0.2) {
            self.detailViewController.blockingView.alpha = 1
        }

        switch type {
        case .watchlist:
            listViewController.showEmtpyWatchlist()
        case .search:
            print("no results for search found")
         default:
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
