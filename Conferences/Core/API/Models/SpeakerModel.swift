//
//  Speaker.swift
//  Conferences
//
//  Created by Timon Blask on 02/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation

struct SpeakerModel: Codable {
    let id: Int
    let firstname: String
    let lastname: String
    let image: String?
    let twitter: String?
    let github: String?
    let about: String?
}


extension SpeakerModel: ListRepresentable {
    var title: String {
        return "\(firstname) \(lastname)"
    }

    var subtitle: String {
        return twitter != nil ? "@\(twitter ?? "")" : ""
    }

    var detail: String? {
        return about
    }

    var children: [ListRepresentable]? {
        return nil
    }

    var color: String? {
        return nil
    }
}
