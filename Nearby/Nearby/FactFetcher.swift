//
//  FactFetcher.swift
//  Nearby
//
//  Created by Sai Samarth Patipati Umesh on 4/22/24.
//

import Foundation
import Combine
import GoogleGenerativeAI

class FactFetcher: ObservableObject {
    @Published var facts: [Fact] = []
    
    init() {
         // Mock data for testing
         self.facts = [
             Fact(title: "Fact 1", description: "Description 1"),
             Fact(title: "Fact 2", description: "Description 2")
            
             // Add more facts here
         ]
        
        Task {
            await loadContent()
        }
        print("here1")
     }
    
    enum APIKey {
      /// Fetch the API key from `GenerativeAI-Info.plist`
      /// This is just *one* way how you can retrieve the API key for your app.
      static var `default`: String {
        guard let filePath = Bundle.main.path(forResource: "GenerativeAI-Info", ofType: "plist")
        else {
          fatalError("Couldn't find file 'GenerativeAI-Info.plist'.")
        }
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
          fatalError("Couldn't find key 'API_KEY' in 'GenerativeAI-Info.plist'.")
        }
        if value.starts(with: "_") || value.isEmpty {
          fatalError(
            "Follow the instructions at https://ai.google.dev/tutorials/setup to get an API key."
          )
        }
        return value
      }
    }
    
    func loadFacts(latitude: Double, longitude: Double) {
        // Your existing code to load facts from an API
    }
    
    func loadContent() async {
        do {
            print("here2")
            let model = GenerativeModel(name: "gemini-pro", apiKey: APIKey.default)
            let prompt = "Write a story about a magic backpack."
            let response = try await model.generateContent(prompt)
            if let text = response.text {
                print(text) // Handle the response text
            }
        } catch {
            print("Error generating content: \(error)")
        }
    }
}

    
    
    

//    func loadFacts(latitude: Double, longitude: Double) {
//        guard let url = URL(string: "https://api.gemini.com/location/\(latitude),\(longitude)/facts") else { return }
//        
//        var request = URLRequest(url: url)
//        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
//        
//        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
//            if let data = data {
//                do {
//                    let decodedResponse = try JSONDecoder().decode([Fact].self, from: data)
//                    DispatchQueue.main.async {
//                        self?.facts = decodedResponse
//                    }
//                } catch {
//                    print("Decoding failed: \(error.localizedDescription)")
//                }
//            } else if let error = error {
//                print("Fetch failed: \(error.localizedDescription)")
//            }
//        }.resume()
//    }

