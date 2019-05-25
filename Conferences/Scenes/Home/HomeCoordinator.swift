//
//  HomeCoordinator.swift
//  Conferences
//
//  Created by Zagahr on 27/04/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

final class HomeCoordinator: Coordinator {

    lazy var vc: UIViewController = {
        let navigationController = UINavigationController(rootViewController: homeViewController)

        return navigationController
    }()

    lazy var homeViewController: HomeViewController = {
        let vc = HomeViewController()
        vc.title = "Home"
        vc.coordinator = self
        vc.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: "home"), selectedImage: nil)

        return vc
    }()

    func start() {
        var sections = Config.shared.homeSections

        for (index, section) in sections.enumerated() {
            switch section.target {
            case .conference:
                sections[index].items = TalkService.filterConferences(by: sections[index].filter)
            case .speaker:
                 sections[index].items = TalkService.filterSpeakers(by: sections[index].filter)
            case .talk:
                sections[index].items = TalkService.filterTalks(by: sections[index].filter)
            }
        }

        sections = sections.filter { !$0.items.isEmpty }
        homeViewController.sections = sections
        homeViewController.showSections()
    }
}

extension HomeCoordinator: HomeSectionControllerDelegate {
    func handle(section: HomeSection, item: ListRepresentable) {
        guard let navigation = vc as? UINavigationController else { return }

        switch section.target {
        case .conference:
            guard let conference = item as? ConferenceModel else { return }

            let coordinator = SplitCoordinator(type: .conference(conference.name, [item], item))
            coordinator.present(inside: navigation)
        case .speaker:
            guard let speaker = item as? SpeakerModel else { return }

            let coordinator = SplitCoordinator(type: .speaker("\(speaker.firstname) \(speaker.lastname)", item))
            coordinator.present(inside: navigation)
        case .talk:
            guard let talk = item as? TalkModel else { return }

            let vc = DetailViewController()
            vc.configureView(with: talk)
            vc.hidesBottomBarWhenPushed = true
            navigation.pushViewController(vc, animated: true)
        }
    }
}
