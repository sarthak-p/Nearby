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
//         self.facts = [
//             Fact(title: "Fact 1", description: "Description 1"),
//             Fact(title: "Fact 2", description: "Description 2")
//         ]
        
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
        guard let value = plist?.object(forKey: "GEMINI_API_KEY") as? String else {
          fatalError("Couldn't find key 'GEMINI_API_KEY' in 'GenerativeAI-Info.plist'.")
        }
        if value.starts(with: "_") || value.isEmpty {
          fatalError(
            "Follow the instructions at https://ai.google.dev/tutorials/setup to get an API key."
          )
        }
        return value
      }
    }
    
//    func loadFacts(latitude: Double, longitude: Double) {
//        // Your existing code to load facts from an API
//    }
    
    func loadContent() async {
        do {
            print("here2")
            let model = GenerativeModel(name: "gemini-pro", apiKey: APIKey.default)
            let locationName = "Westmont, Chicago" // Example location name

            let prompt = """
            Give a detailed report on \(locationName) including very interesting historical facts, notable events, cultural significance, intriguing and obscure details, lesser-known aspects,  and hidden gems that most people might not know.
                               provid intriguing and obscure details about the location that most people might not know. Everything must be things people do not know about the place. Please provide each fact with a concise title(must be captivating) and a more detailed description. Give me atleast 10 results. The results must be returned in a JSON that is structured like this:
            {
              "location": "\(locationName)",
              "facts": [
                {
                  "title": "Title of Fact 1",
                  "description": "Detailed description of Fact 1",
                  "imageUrl": "https://example.com/path/to/image1.jpg"
                },
                {
                  "title": "Title of Fact 2",
                  "description": "Detailed description of Fact 2",
                  "imageUrl": "https://example.com/path/to/image2.jpg"
                },
                {
                  "title": "Title of Fact 3",
                  "description": "Detailed description of Fact 3",
                  "imageUrl": "https://example.com/path/to/image3.jpg"
                }
                // Additional facts can be added in the same structure
              ]
            }
            Each fact must be unique and informative, aimed at enlightening even the locals who think they know all there is about the place.
            """
            let response = try await model.generateContent(prompt)
            if let text = response.text {
                DispatchQueue.main.async {
                        self.parseFactsFromResponse(text)
                }
                print(text) // Handle the response text
            }
        } catch {
            print("Error generating content: \(error)")
        }
    }
    
    private func parseFactsFromResponse(_ response: String) {
        
        let pattern = #"""
        "title": "(.*?)",
        "description": "(.*?)",
        "imageUrl": "(.*?)"
        """#
        
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let results = regex.matches(in: response, options: [], range: NSRange(response.startIndex..., in: response))

        DispatchQueue.main.async {
            self.facts = results.map {
                let titleRange = Range($0.range(at: 1), in: response)!
                let descriptionRange = Range($0.range(at: 2), in: response)!
                let imageUrlRange = Range($0.range(at: 3), in: response)!

                return Fact(
                    title: String(response[titleRange]),
                    description: String(response[descriptionRange]),
                    imageUrl: String(response[imageUrlRange])
                )
            }
        }
        
//        do {
//            let jsonData = Data(response.utf8)
//            let responseStructure = try JSONDecoder().decode(ResponseStructure.self, from: jsonData)
//            DispatchQueue.main.async {
//                print("here3")
//                self.facts = responseStructure.facts.map {
//                    Fact(id: nil, title: $0.title, description: $0.description)
//                }
//            }
//        } catch {
//            print("Error parsing JSON: \(error)")
//        }
    }
    
    struct ResponseStructure: Codable {
        let location: String
        let facts: [Fact]
    }
    
    
}

    

