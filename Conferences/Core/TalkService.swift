//
//  TalkService.swift
//  Conferences
//
//  Created by Timon Blask on 13/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation

protocol TalkServiceDelegate: class {
    func didFetch(_ conferences: [ConferenceViewModel])
    func fetchFailed(with error: APIError)
}

final class TalkService {
    weak var delegate: TalkServiceDelegate?

    private var conferences: [ConferenceViewModel] = []
    private var backup: [ConferenceViewModel] = []

    func fetchData(type: PresentationType ) {
        let models = APIClient.shared.models.map { ConferenceViewModel(conferenceModel: $0) }
        self.conferences = models
        self.backup = models

        switch type {
        case .watchlist:
            filterTalks(by: type.filter)
        default:
            DispatchQueue.main.async {
                self.delegate?.didFetch(self.conferences)
            }
        }
    }

    func filterTalks(by searchString: String) {
        let activeTags = TagSyncService.shared.activeTags()
        
        var currentBatch = self.backup
        
        for (index, var conference) in currentBatch.enumerated() {
            if (searchString.count > 0) {
                conference.talks = conference.talks.filter { $0.matches(searchCriteria: searchString) && $0.matchesAll(activeTags: activeTags) }
            } else {
                conference.talks = conference.talks.filter { $0.matchesAll(activeTags: activeTags) }
            }

             currentBatch[index] = conference
        }
        
        currentBatch = currentBatch.filter { !$0.talks.isEmpty }
        
        self.conferences = currentBatch
        
        DispatchQueue.main.async {
            self.delegate?.didFetch(self.conferences)
        }
    }

    @objc private func filterTalks() {
        //filterTalks(by: delegate?.getSearchText() ?? "")
    }
    
    func getSuggestions(basedOn: String?) -> [Suggestion] {
        guard let based = basedOn else { return [] }

        var ret: [Suggestion] = []
        let activeTags = TagSyncService.shared.activeTags()
        
        for conference in self.backup {
            for talk in conference.talks {
                
                if (talk.speaker.firstname.lowercased().contains(based.lowercased()) && talk.matchesAll(activeTags: activeTags)) {
                    if let existingSuggestion = ret.filter ({ $0.completeWord == talk.speaker.firstname.lowercased() }).first {
                        existingSuggestion.add(source: .speakerFirstname, for: talk)
                        existingSuggestion.add(talk: talk)
                    }
                    else {
                        let newSuggestion = Suggestion(text: based, completeWord: talk.speaker.firstname.lowercased())
                        newSuggestion.add(source: .speakerFirstname, for: talk)
                        newSuggestion.add(talk: talk)
                        ret.append(newSuggestion)
                    }
                }
                
                if (talk.speaker.lastname.lowercased().contains(based.lowercased()) && talk.matchesAll(activeTags: activeTags)) {
                    if let existingSuggestion = ret.filter ({ $0.completeWord == talk.speaker.lastname.lowercased() }).first {
                        existingSuggestion.add(source: .speakerLastname, for: talk)
                        existingSuggestion.add(talk: talk)
                    }
                    else {
                        let newSuggestion = Suggestion(text: based, completeWord: talk.speaker.lastname.lowercased())
                        newSuggestion.add(source: .speakerLastname, for: talk)
                        newSuggestion.add(talk: talk)
                        ret.append(newSuggestion)
                    }
                }
                
                if ((talk.speaker.twitter?.lowercased().contains(based.lowercased()) ?? false) && talk.matchesAll(activeTags: activeTags)) {
                    if let existingSuggestion = ret.filter ({ $0.completeWord == talk.speaker.twitter?.lowercased() }).first {
                        existingSuggestion.add(source: .twitter, for: talk)
                        existingSuggestion.add(talk: talk)
                    }
                    else {
                        let newSuggestion = Suggestion(text: based, completeWord: talk.speaker.twitter?.lowercased() ?? "")
                        newSuggestion.add(source: .twitter, for: talk)
                        newSuggestion.add(talk: talk)
                        ret.append(newSuggestion)
                    }
                }
                
                let pattern = "[^A-Za-z0-9\\-]+"
                
                var result = talk.title.replacingOccurrences(of: pattern, with: " ", options: [.regularExpression])
                for word in result.components(separatedBy: " ") {
                    if (word.lowercased().contains(based.lowercased()) && talk.matchesAll(activeTags: activeTags)) {
                        if let existingSuggestion = ret.filter ({ $0.completeWord == word.lowercased() }).first {
                            existingSuggestion.add(source: .title, for: talk)
                            existingSuggestion.add(talk: talk)
                        }
                        else {
                            let newSuggestion = Suggestion(text: based, completeWord: word.lowercased())
                            newSuggestion.add(source: .title, for: talk)
                            newSuggestion.add(talk: talk)
                            ret.append(newSuggestion)
                        }
                    }
                }
                
                result = talk.details?.replacingOccurrences(of: pattern, with: " ", options: [.regularExpression]) ?? ""
                for word in result.components(separatedBy: " ") {
                    if (word.lowercased().contains(based.lowercased()) && talk.matchesAll(activeTags: activeTags)) {
                        if let existingSuggestion = ret.filter({ $0.completeWord == word.lowercased() }).first {
                            existingSuggestion.add(source: .details, for: talk)
                            existingSuggestion.add(talk: talk)
                        }
                        else {
                            let newSuggestion = Suggestion(text: based, completeWord: word.lowercased())
                            newSuggestion.add(source: .details, for: talk)
                            newSuggestion.add(talk: talk)
                            ret.append(newSuggestion)
                        }
                    }
                }
            }
        }
        
        return ret.sorted { $0.inTalks.count > $1.inTalks.count }
    }
}
