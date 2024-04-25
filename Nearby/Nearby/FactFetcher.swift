//
//  FactFetcher.swift
//  Nearby
//
//  Created by Sai Samarth Patipati Umesh on 4/22/24.
//

import Foundation
import Combine

class FactFetcher: ObservableObject {
    @Published var facts: [Fact] = []

    private var apiKey: String {
        guard let filePath = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath),
              let value = plist.object(forKey: "GeminiApiKey") as? String else {
            fatalError("Couldn't find key 'GeminiApiKey' in 'Config.plist'.")
        }
        return value
    }

    func loadFacts(latitude: Double, longitude: Double) {
        guard let url = URL(string: "https://api.gemini.com/location/\(latitude),\(longitude)/facts") else { return }
        
        var request = URLRequest(url: url)
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let data = data {
                do {
                    let decodedResponse = try JSONDecoder().decode([Fact].self, from: data)
                    DispatchQueue.main.async {
                        self?.facts = decodedResponse
                    }
                } catch {
                    print("Decoding failed: \(error.localizedDescription)")
                }
            } else if let error = error {
                print("Fetch failed: \(error.localizedDescription)")
            }
        }.resume()
    }
}

