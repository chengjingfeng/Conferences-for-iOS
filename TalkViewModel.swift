//
//  TalkViewModel.swift
//  Conferences
//
//  Created by Zagahr on 06/05/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation
import RealmSwift
import ConferencesCore
import DifferenceKit

struct TalkViewModel {
    var id: Int
    var title: String
    var url: URL?
    var source: VideoSourceModel
    var videoId: String
    var details: String?
    var speaker: SpeakerModel
    var highlightColor: String
    var tags: [String]
    var watched: Bool
    var onWatchlist: Bool
    var progress: ProgressModel?

    var image: URL? {
        return URL(string: "\(Environment.url)/preview/previewImage-\(videoId).jpeg")
    }

    init(talkModel: TalkModel) {
        self.id = talkModel.id
        self.title = talkModel.title
        self.url = URL(string: talkModel.url)
        self.source = talkModel.source
        self.videoId = talkModel.videoId
        self.details = talkModel.details
        self.speaker = talkModel.speaker
        self.highlightColor = talkModel.highlightColor
        self.tags = talkModel.tags
        self.progress = Storage.shared.getProgress(for: talkModel.id)
        self.watched = progress?.watched ?? false
        self.onWatchlist = Storage.shared.isOnWatchlist(for: self.id)?.active ?? false
    }
}


extension TalkViewModel: Differentiable {
    var differenceIdentifier: Int {
        return id
    }

    func isContentEqual(to source: TalkViewModel) -> Bool {
        return self == source
    }
}

extension TalkViewModel: Equatable {
    static func == (lhs: TalkViewModel, rhs: TalkViewModel) -> Bool {
        return lhs.id == rhs.id && lhs.onWatchlist == rhs.onWatchlist && lhs.watched == rhs.watched && lhs.progress == rhs.progress
    }
}

extension TalkViewModel: Searchable {
    var searchString: String {
        return #"""
            \#(title)
            \#(details ?? "")
            \#(speaker.firstname)
            \#(speaker.lastname)
            \#(speaker.twitter ?? "")
            \#(tags.joined(separator: " "))
            \#(onWatchlist ? "realm_watchlist" : "")
            \#((progress?.watched == false && progress?.currentPosition != 0.0) ? "realm_continue" : "")
            """#
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "\n", with: "")
    }
}

//extension TalkViewModel {
//    var watched: Bool {
//        get {
//            return progress?.watched ?? false
//        }
//
//        set {
//            let watched = newValue ? 1.0 : 0.0
//            trackProgress(currentPosition: 0, relativePosition: watched)
//        }
//    }
//
//
//    var onWatchlist: Bool {
//        get {
//            return Storage.shared.isOnWatchlist(for: self.id)?.active ?? false
//        }
//
//        set {
//            let model = WatchlistModel()
//            model.id = self.id
//            model.active = newValue
//
//            Storage.shared.setFavorite(model)
//        }
//    }
//
//    var currentlyPlaying: Bool {
//        get {
//            return Storage.shared.currentlyWatching(for: self.id)
//        }
//
//        set {
//            let model = CurrentlyWatchingModel()
//            model.id = self.id
//
//            Storage.shared.currentlyWatching(object: model)
//        }
//    }
//}

extension TalkViewModel {
    func trackProgress(currentPosition: Double, relativePosition: Double) {
        let model = ProgressModel()
        model.id = self.id
        model.currentPosition = relativePosition >= 0.97 ? 0.0 : currentPosition
        model.relativePosition = relativePosition >= 0.97 ? 1.0 : relativePosition
        model.watched = relativePosition >= 0.97

        Storage.shared.trackProgress(object: model)
    }
}

extension TalkViewModel {
    func matchesAll(activeTags: [TagModel]) -> Bool {
        for active in activeTags {
            if (active.title == TagSyncService.watchedTitle) {
                if (!self.watched) { return false }
            }
            else if (active.title == TagSyncService.notWatchedTitle) {
                if (self.watched) { return false }
            }
            else if (active.title == TagSyncService.watchlistTitle) {
                if (!self.onWatchlist) { return false }
            }
            else if (active.title == TagSyncService.continueWatchingTitle) {
            //    if (!self.currentlyPlaying) { return false }
            }
            else if (self.tags.filter { $0.contains(active.title) }.count == 0) { return false }
        }
        return true
    }

    func matches(searchCriteria: String) -> Bool {
        guard searchCriteria.count > 0 else { return true }

        let components = searchCriteria.components(separatedBy: SuggestionSourceEnum.sourceCriteriaLimit)

        // TODO: Seach with multiple "key:text" criterias
        if (components.count == 2 && SuggestionSourceEnum.isSource(text: components.first ?? "")) {

            if (components.first == SuggestionSourceEnum.speakerFirstname.rawValue.text) {
                return self.speaker.firstname.lowercased().contains(components.last?.lowercased() ?? "") ||
                    self.speaker.lastname.lowercased().contains(components.last?.lowercased() ?? "")
            }
            else if (components.first == SuggestionSourceEnum.title.rawValue.text) {
                return self.title.lowercased().contains(components.last?.lowercased() ?? "")
            }
            else if (components.first == SuggestionSourceEnum.twitter.rawValue.text) {
                return self.speaker.twitter?.lowercased().contains(components.last?.lowercased() ?? "") ?? false
            }
            else if (components.first == SuggestionSourceEnum.details.rawValue.text) {
                return self.details?.lowercased().contains(components.last?.lowercased() ?? "") ?? false
            }
            else {
                return false
            }
        }
        else {
            return self.searchString.contains(searchCriteria.lowercased())
        }
    }
}

extension MutableCollection {
    mutating func mapInPlace(_ x: (inout Element) -> ()) {
        for i in indices {
            x(&self[i])
        }
    }
}
