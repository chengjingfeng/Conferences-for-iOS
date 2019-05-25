//
//  Theme.swift
//  Conferences
//
//  Created by Zagahr on 24/05/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

struct AppTheme {
    var statusBarStyle: UIStatusBarStyle
    var backgroundColor: UIColor
    var secondaryBackgroundColor: UIColor
    var textColor: UIColor
    var secondaryTextColor: UIColor
    var shadow: Bool
}

extension AppTheme {
    static let light = AppTheme(
        statusBarStyle: .default,
        backgroundColor: UIColor(red:0.90, green:0.90, blue:0.90, alpha:1.0),
        secondaryBackgroundColor: UIColor(red:0.80, green:0.80, blue:0.80, alpha: 1.0),
        textColor: .black,
        secondaryTextColor: .darkGray,
        shadow: true
    )

    static let dark = AppTheme(
        statusBarStyle: .lightContent,
        backgroundColor: .panelBackground,
        secondaryBackgroundColor: .elementBackground,
        textColor: .white,
        secondaryTextColor: .lightGray,
        shadow: false
    )

    static let darker = AppTheme(
        statusBarStyle: .lightContent,
        backgroundColor: .elementBackground,
        secondaryBackgroundColor: .black,
        textColor: .white,
        secondaryTextColor: .lightGray,
        shadow: false
    )

    static let black = AppTheme(
        statusBarStyle: .lightContent,
        backgroundColor: .black,
        secondaryBackgroundColor: .elementBackground,
        textColor: .white,
        secondaryTextColor: .lightGray,
        shadow: false
    )
}

extension AppTheme: Equatable {
    static func == (lhs: AppTheme, rhs: AppTheme) -> Bool {
        return lhs.statusBarStyle.rawValue == rhs.statusBarStyle.rawValue
    }
}
