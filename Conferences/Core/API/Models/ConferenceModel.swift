//
//  Conferences.swift
//  Conferences
//
//  Created by Timon Blask on 02/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation
import ConferencesCore
import DifferenceKit

struct ConferenceModel: Codable {
    let id: Int
    let organisator: OrganisatorModel
    let name: String
    let url: String
    let location: String
    let date: String
    let highlightColor: String
    let talks: [TalkModel]
    let about: String
}
