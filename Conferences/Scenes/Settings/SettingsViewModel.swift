//
//  SettingsViewModel.swift
//  Conferences
//
//  Created by Zagahr on 08/04/2019.
//  Copyright © 2019 Timon Blask. All rights reserved..
//

import Foundation


enum Settings: CaseIterable {
    case data
    case conferences
    
    var title: String {
        switch self {
        case .data:
            return "Don't know yet"
        case .conferences:
            return "Conferences"
        }
    }
    
    var entrys: [Entry] {
        switch self {
        case .data:
            return [.dontKnow]
        case .conferences:
            return [.writeReview, .tellFriend, .licenses, .reportAProblem, .contributors]
        }
    }
    
    enum Entry {
        case tellFriend, licenses, writeReview, reportAProblem, contributors, dontKnow
        
        var title: String {
            switch self {
            case .dontKnow:
                return "Don't know yet"
            case .writeReview:
                return "Write a Review"
            case .tellFriend:
                return "Tell a Friend"
            case .licenses:
                return "Licences/Credits"
            case .reportAProblem:
                return "Report a Problem"
            case .contributors:
                return "Contributors"
            }
        }
    }
}


final class SettingsViewModel {
    weak var coordinatorDelegate: SettingsCoordinatorDelegate?
    
    var numberOfSections: Int {
        return Settings.allCases.count
    }
    
    func titleFor(section: Int) -> String {
        return Settings.allCases.indices.contains(section) ? Settings.allCases[section].title : ""
    }
    
    func numberOfRows(at section: Int) -> Int {
        return Settings.allCases.indices.contains(section) ? Settings.allCases[section].entrys.count : 0
    }
    
    func model(at index: IndexPath) -> Settings.Entry {
        guard let settings = Settings.allCases[safe: index.section] else { fatalError("Section out of bounds") }
        guard let entry = settings.entrys[safe: index.row] else { fatalError("Index out of bounds") }
        
        return entry
    }
    
    func didSelectCell(at indexPath: IndexPath) {
//        guard let entry = Settings.allCases[safe: indexPath.section]?.entrys[safe: indexPath.row] else { return }
//
//        switch entry {
//        case .tellFriend:
//            coordinatorDelegate?.showRecommendApp()
//        case .licenses:
//            coordinatorDelegate?.showLicences()
//        case .writeReview:
//            coordinatorDelegate?.writeReview()
//            default:
//            print("not implemnted")
//        }
    }
}

extension Collection {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
