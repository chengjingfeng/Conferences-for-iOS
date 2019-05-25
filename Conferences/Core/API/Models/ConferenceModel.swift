//
//  Conferences.swift
//  Conferences
//
//  Created by Timon Blask on 02/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation
import ConferencesCore

protocol ListRepresentable: Codable {
    var id: Int { get }
    var title: String { get }
    var subtitle: String { get }
    var detail: String? { get }
    var children: [ListRepresentable]? { get }
    var image: String? { get }
    var color: String? { get }
}


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

extension ConferenceModel: ListRepresentable {
    var title: String {
        return name
    }

    var subtitle: String {
        return location
    }

    var detail: String? {
        return about
    }

    var children: [ListRepresentable]? {
        return talks
    }

    var image: String? {
        return logo
    }

    var color: String? {
        return nil
    }

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
