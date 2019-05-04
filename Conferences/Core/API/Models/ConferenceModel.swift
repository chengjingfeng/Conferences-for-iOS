//
//  Conferences.swift
//  Conferences
//
//  Created by Timon Blask on 02/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation
import ConferencesCore

struct ConferenceModel: Codable {
    let id: Int
    let organisator: OrganisatorModel
    let name: String
    let url: String
    let location: String
    let date: String
    let highlightColor: String
    var talks: [TalkModel]
    let about: String
}

extension ConferenceModel: Searchable {
    var searchString: String {
        return "\(date) \(location)  \(name)\(organisator.name)".lowercased()
    }
}

extension ConferenceModel {
    var logo: String {
        return "\(Environment.url)/conferences/\(organisator.id).png" 
    }
}
