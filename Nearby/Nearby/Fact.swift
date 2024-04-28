//
//  Fact.swift
//  Nearby
//
//  Created by Sai Samarth Patipati Umesh on 4/24/24.
//
import Foundation

struct Fact: Identifiable, Codable {
    var id: UUID = UUID()
    let title: String
    let description: String
    let imageUrl: String

    init(id: UUID? = nil, title: String, description: String, imageUrl: String) {
        
        self.title = title
        self.description = description
        self.imageUrl = imageUrl
    }
    
//    enum CodingKeys: String, CodingKey {
//        case id, title, description, imageUrl
//    }
}

