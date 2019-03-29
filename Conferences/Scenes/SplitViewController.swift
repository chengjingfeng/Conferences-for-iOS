//
//  SplitViewController.swift
//  Conferences
//
//  Created by Zagahr on 26/03/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

protocol SplitViewDelegate: class {
    func didSelectTalk(talk: TalkModel)
}

final class SplitViewController: UISplitViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        configureView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var listViewController: UINavigationController = {
        let listViewController = ListViewController()
        listViewController.title = "Conferences"
        listViewController.splitDelegate = self


        let navigationController = UINavigationController(rootViewController: listViewController)
        navigationController.navigationBar.barTintColor = UIColor.elementBackground
        navigationController.navigationBar.tintColor = UIColor.white
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        listViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), landscapeImagePhone: UIImage(named: "settings"), style: .plain, target: nil, action: nil)

        return navigationController
    }()

    private lazy var detailViewController: DetailViewController = {
        let detailViewController = DetailViewController()

        return detailViewController
    }()

    private func configureView() {
        self.delegate = self
        self.minimumPrimaryColumnWidth = 380
        self.maximumPrimaryColumnWidth = 400
        self.view.backgroundColor = .elementBackground
        self.preferredDisplayMode = .allVisible
        self.viewControllers = [listViewController, detailViewController]
    }
}

extension SplitViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}

extension SplitViewController: SplitViewDelegate {
    func didSelectTalk(talk: TalkModel) {
        detailViewController.configureView(with: talk)
        detailViewController.navigationItem.leftBarButtonItem = self.displayModeButtonItem
        detailViewController.navigationItem.leftItemsSupplementBackButton = true

        showDetailViewController(detailViewController, sender: nil)
    }
}
