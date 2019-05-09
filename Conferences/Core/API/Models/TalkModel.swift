//
//  Talk.swift
//  Conferences
//
//  Created by Timon Blask on 02/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation
import RealmSwift
import ConferencesCore
import DifferenceKit

struct TalkModel: Codable {
    let id: Int
    let title: String
    let url: String
    let source: VideoSourceModel
    let videoId: String
    let details: String?
    let speaker: SpeakerModel
    let highlightColor: String
    let tags: [String]
}
