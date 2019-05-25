//
//  TagSyncService.swift
//  Conferences
//
//  Created by Timon Blask on 08/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation

final class TagSyncService {
    public static let shared = TagSyncService()

    static let watchedTitle: String    = "Watched"
    static let notWatchedTitle: String = "Not watched"
    static let watchlistTitle: String  = "Watchlist"
    static let continueWatchingTitle: String = "Continue watching"

    private var realmTags: [TagModel] {
        var realmTags: [TagModel] = []

        if !Storage.shared.getWatchlist().isEmpty {
            realmTags.append(.init(title: TagSyncService.watchlistTitle, query: "realm_watchlist"))
        }

        return realmTags
    }

    private let contentTags: [TagModel] = [
        .init(title: "Swift"),
        .init(title: "Objective-C"),
        .init(title: "2019"),
        .init(title: "2018"),
        .init(title: "iOS"),
        .init(title: "macOS")
    ]
    
    private let watchedTags: [TagModel] = [
        .init(title: watchedTitle),
        .init(title: notWatchedTitle)
    ]

    private var defaultTags: [TagModel] {
        return [realmTags, watchedTags, contentTags].flatMap { $0 }
    }

    var tags: [TagModel] = []

    init() {
        self.tags = defaultTags
    }

    func handleTag(_ tag: inout TagModel) {
        if tag.isActive && !contains(tags, tag) && !contains(defaultTags, tag) {
            tags.append(tag)
        } else if !tag.isActive && contains(tags, tag) {
            if contains(defaultTags, tag) {
                if let index = tags.firstIndex(where: { $0.query == tag.query }) {
                    tags[index] = tag
                }
            } else {
                tags = tags.filter { $0.query != tag.query}
            }
        } else if tag.isActive && contains(tags, tag) {
            if let index = tags.firstIndex(where: { $0.query == tag.query }) {
                tags[index] = tag
            }
        }
    }

    func handleStoredTag(_ tag: inout TagModel) {
        if tag.isActive && !contains(tags, tag) {
            loop: for (index, element) in defaultTags.enumerated() {
                if element.query == tag.query {
                    tag.isActive = false
                    tags.insert(tag, at: index)
                    break loop
                }
            }
        } else if !tag.isActive && contains(tags, tag) && !contains(defaultTags, tag) {
            tags = tags.filter { $0.query != tag.query }
        }
    }

    private func contains(_ tags: [TagModel], _ tag: TagModel) -> Bool {
        return tags.first(where: {$0.query == tag.query}) != nil
    }
    
    func activeTags() -> [TagModel] {
        return tags.filter { $0.isActive }
    }
}
