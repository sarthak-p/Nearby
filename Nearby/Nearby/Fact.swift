//
//  Fact.swift
//  Nearby
//
//  Created by Sai Samarth Patipati Umesh on 4/24/24.
//
import Foundation

struct Fact: Codable, Identifiable {
    var id: UUID { UUID() } // For identifiable conformance, assuming each fact has a unique id
    let title: String
    let description: String
}
