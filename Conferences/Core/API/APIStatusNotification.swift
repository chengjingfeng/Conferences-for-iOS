//
//  APIStatusNotification.swift
//  Conferences
//
//  Created by Zagahr on 28/04/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

extension Notification.Name {
    static let apiStatusChanged = Notification.Name("APIStatusChangedNotification")
}

@objc protocol APIStatus {
    @objc func start()
}

extension APIStatus {
    func registerForStatusChange() {
        NotificationCenter.default.addObserver(self, selector: #selector(start), name: .apiStatusChanged, object: nil)
    }
}
