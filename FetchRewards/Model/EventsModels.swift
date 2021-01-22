//
//  EventsModels.swift
//  FetchRewards
//
//  Created by Arseniy Oddler on 1/20/21.
//

import Foundation

/*
   Model should have exactly the same structure as JSON
   I included only fields that we need in our test project.
   To keep structure clear and short, I use small amount of them.
   Also I will not mark them as optionals (it is possible that we will not get these fields inside the JSON)
   to keep the code short
 */

struct ReceivedPage: Codable {
    let events: [Event]
    let meta: Meta

    private enum CodingKeys: String, CodingKey {
        case events, meta
    }
}

struct Event: Codable {
    let id: Int
    let localDateTime: String
    let title: String
    let performers: [Performer]

    private enum CodingKeys: String, CodingKey {
        case id
        case localDateTime = "datetime_local"
        case title
        case performers
    }
}

struct Meta: Codable {
    let eventsPerPage: Int
    let currentPage: Int

    private enum CodingKeys: String, CodingKey {
        case eventsPerPage = "per_page"
        case currentPage = "page"
    }
}

struct Performer: Codable {
    let name: String
    let imageUrl: String

    private enum CodingKeys: String, CodingKey {
        case name
        case imageUrl = "image"
    }
}
