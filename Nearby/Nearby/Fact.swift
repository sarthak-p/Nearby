//
//  Fact.swift
//  Nearby
//
//  Created by Sai Samarth Patipati Umesh on 4/24/24.
//
import Foundation

struct Fact: Identifiable, Codable {
    var id: UUID
    let title: String
    let description: String
    let imageUrl: String

    enum CodingKeys: String, CodingKey {
        case title, description, imageUrl
    }

    init(title: String, description: String, imageUrl: String) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.imageUrl = imageUrl
    }

    // Custom initializer for decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        id = UUID() // Generate a new UUID
    }
}

