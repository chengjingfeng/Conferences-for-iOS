//
//  TalkService.swift
//  Conferences
//
//  Created by Timon Blask on 13/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation

final class TalkService {
    static func fetchData(type: PresentationType ) -> [ListRepresentable]{
        let models = APIClient.shared.models

        switch type {
        case .watchlist:
            return filterConferences(by: type.filter)
        case .speaker(let filter, _):
            return filterConferences(by: filter)
        default:
            return models
        }
    }

    static func filterConferences(by searchString: String) -> [ConferenceModel] {
        let activeTags = TagSyncService.shared.activeTags()
        
        var currentBatch = APIClient.shared.models
        
        for (index, var conference) in currentBatch.enumerated() {
            if (searchString.count > 0) {
                conference.talks = conference.talks.filter { $0.matches(searchCriteria: searchString) && $0.matchesAll(activeTags: activeTags) }
            } else {
                conference.talks = conference.talks.filter { $0.matchesAll(activeTags: activeTags) }
            }

             currentBatch[index] = conference
        }

        return currentBatch.filter { !$0.talks.isEmpty }
    }

    static func filterTalks(by searchString: String) -> [TalkModel] {
        let activeTags = TagSyncService.shared.activeTags()

        var currentBatch = APIClient.shared.models

        for (index, var conference) in currentBatch.enumerated() {
            if (searchString.count > 0) {
                conference.talks = conference.talks.filter { $0.matches(searchCriteria: searchString) && $0.matchesAll(activeTags: activeTags) }
            } else {
                conference.talks = conference.talks.filter { $0.matchesAll(activeTags: activeTags) }
            }

            currentBatch[index] = conference
        }

        currentBatch = currentBatch.filter { !$0.talks.isEmpty }


        return currentBatch.flatMap { $0.talks }
    }

    static func filterSpeakers(by searchString: String) -> [SpeakerModel] {
        let activeTags = TagSyncService.shared.activeTags()

        var currentBatch = APIClient.shared.models

        for (index, var conference) in currentBatch.enumerated() {
            if (searchString.count > 0) {
                conference.talks = conference.talks.filter { $0.matches(searchCriteria: searchString) && $0.matchesAll(activeTags: activeTags) }
            } else {
                conference.talks = conference.talks.filter { $0.matchesAll(activeTags: activeTags) }
            }

            currentBatch[index] = conference
        }

        return currentBatch.flatMap { $0.talks }.compactMap { $0.speaker }
    }
}
