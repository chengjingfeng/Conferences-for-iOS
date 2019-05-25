//
//  SettingsCoordinator.swift
//  Conferences
//
//  Created by Zagahr on 05/04/2019.
//  Copyright © 2019 Timon Blask. All rights reserved..
//

import UIKit
import AcknowList

protocol SettingsCoordinatorDelegate: class {
    func showLanguageSelect()
    func showRecommendApp()
    func showLicences()
    func writeReview()
}


final class SettingsCoordinator {
    
    let rootViewController = UINavigationController()
    
    private lazy var viewModel: SettingsViewModel = {
        let viewModel = SettingsViewModel()
        viewModel.coordinatorDelegate = self
        return viewModel
    }()
    
     func start() {
         let settingsVC = SettingsViewController(style: .grouped)

        settingsVC.viewModel = viewModel
        rootViewController.setViewControllers([settingsVC], animated: true)
    }
}


extension SettingsCoordinator: SettingsCoordinatorDelegate {
    func showLanguageSelect() {
    }
    
    func showRecommendApp() {
        let text = "Get the new OSS Explorer App"
        let controller = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        controller.setValue(NSString(utf8String: "OSS Explorer"), forKey: "subject")
        //controller.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
        controller.completionWithItemsHandler = { activity, success, items, error in
            if success {
               print("success")
            } else {
                print("error")
            }
        }
        self.rootViewController.present(controller, animated: true, completion: nil)
    }
    
    func showLicences() {
        // TODO: Change acknowledgemets
        let path = Bundle.main.path(forResource: "Pods-Conferences-acknowledgements", ofType: "plist")
        let vc = AcknowListViewController(acknowledgementsPlistPath: path)
        vc.title = "Licenses"
        vc.hidesBottomBarWhenPushed = true
        self.rootViewController.pushViewController(vc, animated: true)
    }
    
    func writeReview() {
        // TODO: Change ID
        guard let url = URLBuilder.init(host: "itunes.apple.com", scheme: "itms-apps")
            .add(paths: ["app", "id1252320249"])
            .add(item: "action", value: "write-review")
            .url
            else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
}

final class URLBuilder {
    
    private var components = URLComponents()
    private var pathComponents = [String]()
    
    init(host: String, scheme: String) {
        components.host = host
        components.scheme = scheme
    }
    
    convenience init(host: String, https: Bool = true) {
        self.init(host: host, scheme: https ? "https" : "http")
    }
    
    static func github() -> URLBuilder {
        return URLBuilder(host: "github.com", https: true)
    }
    
    @discardableResult
    func add(path: LosslessStringConvertible) -> URLBuilder {
        pathComponents.append(String(describing: path))
        return self
    }
    
    @discardableResult
    func add(paths: [LosslessStringConvertible]) -> URLBuilder {
        paths.forEach { self.add(path: $0) }
        return self
    }
    
    @discardableResult
    func add(item: String, value: LosslessStringConvertible) -> URLBuilder {
        var items = components.queryItems ?? []
        items.append(URLQueryItem(name: item, value: String(describing: value)))
        components.queryItems = items
        return self
    }
    
    var url: URL? {
        var components = self.components
        if !pathComponents.isEmpty {
            components.path = "/" + pathComponents.joined(separator: "/")
        }
        return components.url
    }
    
}
