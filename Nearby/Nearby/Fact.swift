//
//  Fact.swift
//  Nearby
//
//  Created by Sai Samarth Patipati Umesh on 4/24/24.
//
//import Foundation
//
//struct Fact: Identifiable, Codable {
//    var id: UUID
//    let title: String
//    let description: String
//    let imageUrl: String
//
//    enum CodingKeys: String, CodingKey {
//        case title, description, imageUrl
//    }
//
//    init(title: String, description: String, imageUrl: String) {
//        self.id = UUID()
//        self.title = title
//        self.description = description
//        self.imageUrl = imageUrl
//    }
//
//    // Custom initializer for decoding
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        title = try container.decode(String.self, forKey: .title)
//        description = try container.decode(String.self, forKey: .description)
//        imageUrl = try container.decode(String.self, forKey: .imageUrl)
//        id = UUID() // Generate a new UUID
//    }
//}

import Foundation

struct Fact: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let imageUrl: String
    let url: String
    let latitude: Double
    let longitude: Double

    enum CodingKeys: String, CodingKey {
        case title, description, imageUrl, url, latitude, longitude
    }

    // Provide a default initializer that generates a new UUID
    init(id: UUID = UUID(), title: String, description: String, imageUrl: String, url: String, latitude: Double, longitude: Double) {
        self.id = id
        self.title = title
        self.description = description
        self.imageUrl = imageUrl
        self.url = url
        self.latitude = latitude
        self.longitude = longitude
    }

    // Custom initializer for decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Generate a new UUID if 'id' is not in JSON
        id = UUID()
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        url = try container.decode(String.self, forKey: .url)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
    }
}

struct ResponseStructure: Codable {
    let location: String
    let facts: [Fact]
}

