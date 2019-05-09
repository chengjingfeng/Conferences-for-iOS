//
//  ConferenceViewModel.swift
//  Conferences
//
//  Created by Zagahr on 06/05/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit
import ConferencesCore
import DifferenceKit

struct ConferenceViewModel {
    let id: Int
    let title: String
    let location: String
    let description: String
    let date: String
    var talks: [TalkViewModel]
    let url: URL?
    let organisator: OrganisatorModel
    let highlightColor: UIColor

    var image: String {
        return "\(Environment.url)/conferences/\(organisator.id).png"
    }

    init(conferenceModel: ConferenceModel) {
        self.id = conferenceModel.id
        self.title = conferenceModel.name
        self.location = conferenceModel.location
        self.description = conferenceModel.about
        self.date = conferenceModel.date
        self.talks = conferenceModel.talks.map { TalkViewModel(talkModel: $0) }
        self.url = URL(string: conferenceModel.url)
        self.organisator = conferenceModel.organisator
        self.highlightColor = UIColor().hexStringToUIColor(hex: conferenceModel.highlightColor)
    }
}

extension ConferenceViewModel: Searchable {
    var searchString: String {
        return "\(date) \(location) \(title)\(organisator.name)".lowercased()
    }
}

extension ConferenceViewModel: DifferentiableSection {
    init<C: Swift.Collection>(source: ConferenceViewModel, elements: C) where C.Element == TalkViewModel {
        self.id = source.id
        self.organisator = source.organisator
        self.title = source.title
        self.url = source.url
        self.location = source.location
        self.date = source.date
        self.highlightColor = source.highlightColor
        self.talks = elements.compactMap { $0 }
        self.description = source.description
    }

    var elements: [TalkViewModel] {
        return talks
    }

    typealias Collection = [TalkViewModel]

    var differenceIdentifier: Int {
        return id
    }

    func isContentEqual(to source: ConferenceViewModel) -> Bool {
        return id == source.id && talks == source.talks
    }
}

