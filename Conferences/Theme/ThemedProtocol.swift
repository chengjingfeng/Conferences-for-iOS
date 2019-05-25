//
//  Themed.swift
//  Conferences
//
//  Created by Zagahr on 24/05/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation

protocol Themed {
    associatedtype _ThemeProvider: ThemeProvider

    var themeProvider: _ThemeProvider { get }

    func applyTheme(_ theme: _ThemeProvider.Theme)
}

extension Themed where Self: AnyObject {
    func setUpTheming() {
        applyTheme(themeProvider.currentTheme)
        themeProvider.subscribeToChanges(self) { [weak self] newTheme in
            self?.applyTheme(newTheme)
        }
    }
}

extension Themed where Self: AnyObject {
    var themeProvider: AppThemeProvider {
        return AppThemeProvider.shared
    }
}
