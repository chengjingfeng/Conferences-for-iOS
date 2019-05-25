//
//  HomeViewController.swift
//  Conferences
//
//  Created by Zagahr on 22/05/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    private let scrollStackView = StackScrollView()
    var sections: [HomeSection] = []
    weak var coordinator: HomeCoordinator?


    override func viewDidLoad() {
        super.viewDidLoad()

        configureView()
        setUpTheming()
    }

    func configureView() {
        extendedLayoutIncludesOpaqueBars = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(showSettings))

        view.addSubview(scrollStackView)
        scrollStackView.edgesToSuperview()
    }

    @objc func showSettings() {
        //let coordinator = SettingsCoordinator()
        //coordinator.start()

        //coordinator.rootViewController.modalPresentationStyle = .formSheet

        //present(coordinator.rootViewController, animated: true, completion:nil)

        AppThemeProvider.shared.nextTheme()
    }

    func showSections() {
        for section in sections {
            let sectionController = HomeSectionController(with: section, delegate: coordinator!)

            addChild(sectionController)
            scrollStackView.addArrangedSubview(view: sectionController.view)
        }
    }
}

extension HomeViewController: Themed {
    func applyTheme(_ theme: AppTheme) {
        view.backgroundColor = theme.backgroundColor
        navigationController?.navigationBar.barTintColor = theme.backgroundColor
        navigationController?.navigationBar.tintColor = theme.textColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: theme.textColor]
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: theme.textColor]
    }
}
