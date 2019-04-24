//
//  ConferencesDataSource.swift
//  Conferences
//
//  Created by Pedro L. Diaz Montilla on 06/04/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

protocol ListViewDataSourceDelegate: class {
    func didSelectTalk(_ talk: TalkModel)
    func reload()
}

class ListViewDataSource: NSObject {
    
    weak var delegate: ListViewDataSourceDelegate?

    var conferences: [ConferenceModel] = [] {
        didSet {
            DispatchQueue.main.async {
                if let talk = self.conferences.first?.talks.first,
                    let window = UIApplication.shared.keyWindow,
                    window.traitCollection.horizontalSizeClass == .regular {
                    self.delegate?.didSelectTalk(talk)
                }
                
                self.delegate?.reload()
            }
        }
    }
    
    func getSuggestions(basedOn: String?) -> [Suggestion] {
        var ret: [Suggestion] = []
        
        guard let based = basedOn else { return [] }
        
        for conference in conferences {
            for talk in conference.talks {
                
                if (talk.speaker.firstname.lowercased().contains(based.lowercased())) {
                    if let existingSuggestion = ret.filter ({ $0.completeWord == talk.speaker.firstname.lowercased() }).first {
                        if (existingSuggestion.sources.filter {$0 == .speakerFirstname}.count == 0) {
                            existingSuggestion.sources.append(.speakerFirstname)
                        }
                    }
                    else {
                        let suggestion = Suggestion(text: based, completeWord: talk.speaker.firstname.lowercased())
                        suggestion.sources.append(.speakerFirstname)
                        ret.append(suggestion)
                    }
                }
                
                if (talk.speaker.lastname.lowercased().contains(based.lowercased())) {
                    if let existingSuggestion = ret.filter ({ $0.completeWord == talk.speaker.lastname.lowercased() }).first {
                        if (existingSuggestion.sources.filter {$0 == .speakerLastname}.count == 0) {
                            existingSuggestion.sources.append(.speakerLastname)
                        }
                    }
                    else {
                        let suggestion = Suggestion(text: based, completeWord: talk.speaker.lastname.lowercased())
                        suggestion.sources.append(.speakerLastname)
                        ret.append(suggestion)
                    }
                }
                
                if (talk.speaker.twitter?.lowercased().contains(based.lowercased()) ?? false) {
                    if let existingSuggestion = ret.filter ({ $0.completeWord == talk.speaker.twitter?.lowercased() }).first {
                        if (existingSuggestion.sources.filter {$0 == .twitter}.count == 0) {
                            existingSuggestion.sources.append(.twitter)
                        }
                    }
                    else {
                        let suggestion = Suggestion(text: based, completeWord: talk.speaker.twitter?.lowercased() ?? "")
                        suggestion.sources.append(.twitter)
                        ret.append(suggestion)
                    }
                }

                let pattern = "[^A-Za-z0-9\\-]+"
                
                var result = talk.title.replacingOccurrences(of: pattern, with: " ", options: [.regularExpression])
                for word in result.components(separatedBy: " ") {
                    if (word.lowercased().contains(based.lowercased())) {
                        if let existingSuggestion = ret.filter ({ $0.completeWord == word.lowercased() }).first {
                            if (existingSuggestion.sources.filter {$0 == .title}.count == 0) {
                                existingSuggestion.sources.append(.title)
                            }
                        }
                        else {
                            let suggestion = Suggestion(text: based, completeWord: word.lowercased())
                            suggestion.sources.append(.title)
                            ret.append(suggestion)
                        }
                    }
                }
                
                result = talk.details?.replacingOccurrences(of: pattern, with: " ", options: [.regularExpression]) ?? ""
                for word in result.components(separatedBy: " ") {
                    if (word.lowercased().contains(based.lowercased())) {
                        if let existingSuggestion = ret.filter({ $0.completeWord == word.lowercased() }).first {
                            if (existingSuggestion.sources.filter {$0 == .details}.count == 0) {
                                existingSuggestion.sources.append(.details)
                            }
                        }
                        else {
                            let suggestion = Suggestion(text: based, completeWord: word.lowercased())
                            suggestion.sources.append(.details)
                            ret.append(suggestion)
                        }
                    }
                }
            }
        }
        
        // Remove duplicates and don't include any word in the current searchbar text
//        var ret2: [Suggestion] = []
//        for s in ret {
//            if (!suggestionExists(in: ret2, for: s) && based.components(separatedBy: " ").filter { $0 == s.completeWord }.count == 0) {
//                ret2.append(s)
//            }
//        }
        
//        return ret2
        return ret
    }
    
    private func suggestionExists(in suggestions: [Suggestion], for suggestion: Suggestion) -> Bool {
        for sug in suggestions {
            if (sug.completeWord == suggestion.completeWord) { return true }
        }
        
        return false
    }
}

