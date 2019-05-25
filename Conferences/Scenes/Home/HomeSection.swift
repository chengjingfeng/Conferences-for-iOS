//
//  HomeSection.swift
//  Conferences
//
//  Created by Zagahr on 22/05/2019.
//  Copyright © 2019 Timon Blask. All rights reserved.
//

import UIKit

struct HomeSection: Codable {
    public enum Size: String, Codable {
        case l, m, s
    }

    public enum Target: String, Codable {
        case speaker, conference, talk
    }

    public let title: String?
    public let subtitle: String?
    public let target: Target
    public let filter: String
    public let imageUrl: String?
    public let size: Size

    public var items: [ListRepresentable]

    private enum CodingKeys: String, CodingKey {
        case title
        case subtitle
        case target
        case filter
        case size
        case imageUrl
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        subtitle = try container.decodeIfPresent(String.self, forKey: .subtitle)
        target = try container.decode(Target.self, forKey: .target)
        filter = try container.decode(String.self, forKey: .filter)
        size = try container.decode(Size.self, forKey: .size)
        items = []
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(subtitle, forKey: .subtitle)
        try container.encode(target, forKey: .target)
        try container.encode(filter, forKey: .filter)
        try container.encode(size, forKey: .size)
        try container.encode(imageUrl, forKey: .imageUrl)
    }
}

