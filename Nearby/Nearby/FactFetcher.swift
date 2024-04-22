//
//  FactFetcher.swift
//  Nearby
//
//  Created by Sai Samarth Patipati Umesh on 4/22/24.
//

import Foundation

struct Fact: Codable {
    let title: String
    let description: String
}

class FactFetcher: ObservableObject {
    @Published var facts: [Fact] = []
    
    func loadFacts(latitude: Double, longitude: Double) {
        // Ensure you handle your API URL and key correctly here
        guard let url = URL(string: "https://api.gemini.com/location/\(latitude),\(longitude)/facts") else { return }
        
        var request = URLRequest(url: url)
        
    }
}
