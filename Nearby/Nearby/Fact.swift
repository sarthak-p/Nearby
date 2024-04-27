//
//  Fact.swift
//  Nearby
//
//  Created by Sai Samarth Patipati Umesh on 4/24/24.
//
import Foundation

struct Fact: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String

    init(id: UUID = UUID(), title: String, description: String) {
        self.id = id
        self.title = title
        self.description = description
    }
}

