//
//  Organisator.swift
//  Conferences
//
//  Created by Timon Blask on 02/02/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import Foundation

struct OrganisatorModel: Codable {
    let id: Int
    let name: String
    let twitter: String?
    let nextEvent: String?
}

