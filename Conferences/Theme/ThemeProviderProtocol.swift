//
//  ThemeProvider.swift
//  Conferences
//
//  Created by Zagahr on 24/05/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation

protocol ThemeProvider {
    associatedtype Theme

    var currentTheme: Theme { get }

    func subscribeToChanges(_ object: AnyObject, handler: @escaping (Theme) -> Void)
}
