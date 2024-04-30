//
//  FactFetcher.swift
//  Nearby
//
//  Created by Sai Samarth Patipati Umesh on 4/22/24.
//

import Foundation
import Combine
import GoogleGenerativeAI
import CoreLocation

class FactFetcher: ObservableObject {
    @Published var facts: [Fact] = []
    @Published var isLoading = true
    private var currentLocation: CLLocation?
    private var retryCount = 0
    private let maxRetries = 4 // Maximum number of retries

    init() {
//        Task {
//            await loadContent (with: <#CLLocation?#>)
//        }
    }
    
    func updateLocation(_ location: CLLocation) async {
            currentLocation = location
            // Optionally trigger fetching facts whenever the location updates
             print("here")
        await loadContent()
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
    
    
    
    
    func loadContent() async {
        
        guard let location = currentLocation else {
                    print("Location is not set")
                    return
                }

                isLoading = true
                let locationName = "Aurora, IL"
//        "\(location.coordinate.latitude), \(location.coordinate.longitude)" // Format as needed
                print(locationName)
                
        
            do {
                let model = GenerativeModel(name: "gemini-pro", apiKey: APIKey.default)
//                self.locationName = "Westmont, Chicago" // Example location name


                let prompt = """
                Give a detailed report on \(locationName) including very interesting historical facts, notable events, cultural significance, intriguing and obscure details, lesser-known aspects, and hidden gems that most people might not know. Please provide each fact with a concise title (must be captivating), a more detailed description and an image to accompany the fact. The image url must be from Google and usable in swift. Provide the webpage for the fact, event, places if one exists. Give me at least 10 results. The results must be returned in a valid JSON format with properly quoted fields. Here is an example of how the JSON should look:
                {
                  "location": "\(locationName)",
                  "facts": [
                    {
                      "title": "Title of Fact 1",
                      "description": "Detailed description of Fact 1",
                      "imageUrl": "https://example.com/path/to/image1.jpg"
                      "url": "https://example.com"
                    },
                    {
                      "title": "Title of Fact 2",
                      "description": "Detailed description of Fact 2",
                      "imageUrl": "https://example.com/path/to/image2.jpg"
                      "url": "https://example.com"
                    },
                    {
                      "title": "Title of Fact 3",
                      "description": "Detailed description of Fact 3",
                      "imageUrl": "https://example.com/path/to/image3.jpg"
                      "url": "https://example.com"
                    }
                    // Additional facts can be added in the same structure
                  ]
                }
                Return in exactly the above format. Do not add anything extra before or after.
                """
                let response = try await model.generateContent(prompt)
            
                if let text = response.text {
                    print(text)
                    if isValidJSON(text) {
                        if let jsonData = text.data(using: .utf8) {
                            if validateJSONSchema(jsonData: jsonData) {
                                if let fetchedData = decodeJSON(jsonData: jsonData) {
                                    DispatchQueue.main.async {
                                        self.facts = fetchedData.facts
                                    }
                                } else {
                                    await retryLoadingContent()
                                }
                            } else {
                                await retryLoadingContent()
                            }
                        }
                    } else {
                        await retryLoadingContent()
                    }
                }
                self.isLoading = false
            } catch {
                print("Error generating content: \(error)")
            }
        }
    
    private func retryLoadingContent() async{
        if retryCount < maxRetries {
            retryCount += 1
            print("Retrying... Attempt \(retryCount)")
            await loadContent()
        } else {
            print("Max retries reached. Unable to load valid JSON data.")
        }
    }


    func isValidJSON(_ jsonString: String) -> Bool {
        guard let jsonData = jsonString.data(using: .utf8) else {
            return false
        }
        
        do {
            _ = try JSONSerialization.jsonObject(with: jsonData, options: .fragmentsAllowed)
            return true
        } catch {
            print("Invalid JSON: \(error.localizedDescription)")
            return false
        }
    }
    
    
    func validateJSONSchema(jsonData: Data) -> Bool {
        do {
            if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                guard let facts = jsonObject["facts"] as? [[String: Any]] else {
                    print("Error: 'facts' key is missing or is not an array of dictionaries.")
                    return false
                }

                var factIndex = 0
                for fact in facts {
                    guard fact["title"] is String else {
                        print("Error: 'title' is missing or is not a string in fact at index \(factIndex).")
                        return false
                    }
                    guard fact["description"] is String else {
                        print("Error: 'description' is missing or is not a string in fact at index \(factIndex).")
                        return false
                    }
                    guard fact["imageUrl"] is String else {
                        print("Error: 'imageUrl' is missing or is not a string in fact at index \(factIndex).")
                        return false
                    }
                    factIndex += 1
                }
                return true
            } else {
                print("Error: JSON top-level object is not a dictionary.")
                return false
            }
        } catch {
            print("Error parsing JSON: \(error)")
            return false
        }
    }




    func decodeJSON(jsonData: Data) -> ResponseStructure? {
        let decoder = JSONDecoder()
        do {
            let response = try decoder.decode(ResponseStructure.self, from: jsonData)
            return response
        } catch {
            print("Decoding error: \(error)")
            return nil
        }
    }
}

//    func loadContent() async{
//
//        let jsonString = """
//        {
//          "location": "Westmont, Chicago",
//          "facts": [
//            {
//              "title": "Historical Landmark",
//              "description": "Description of a historical landmark in Westmont, Chicago.",
//              "imageUrl": "https://example.com/image.jpg"
//            }
//          ]
//        }
//        """
//        if isValidJSON(jsonString) {
//            if let jsonData = jsonString.data(using: .utf8) {
//                if validateJSONSchema(jsonData: jsonData) {
//                    if let fetchedData = decodeJSON(jsonData: jsonData) {
//                        DispatchQueue.main.async {
//                            self.facts = fetchedData.facts
//                        }
//                    }
//                }
//            }
//        }
//    }

//    func validateJSONSchema(jsonData: Data) -> Bool {
//        do {
//            if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
//               let facts = jsonObject["facts"] as? [[String: Any]] {
//                for fact in facts {
//                    guard let _ = fact["title"] as? String,
//                          let _ = fact["description"] as? String,
//                          let _ = fact["imageUrl"] as? String else {
//                        print("Missing required fields in facts")
//                        return false
//                    }
//                }
//                return true
//            }
//        } catch {
//            print("Error parsing JSON: \(error)")
//            return false
//        }
//        return false
//    }



//import Foundation
//import Combine
//import GoogleGenerativeAI
//
//class FactFetcher: ObservableObject {
//    @Published var facts: [Fact] = []
//    
//    init() {
//        
//         // Mock data for testing
////         self.facts = [
////             Fact(title: "Fact 1", description: "Description 1"),
////             Fact(title: "Fact 2", description: "Description 2")
////         ]
//        
//        Task {
//            await loadContent()
//        }
//        print("here1")
//     }
//    
//    enum APIKey {
//      /// Fetch the API key from `GenerativeAI-Info.plist`
//      /// This is just *one* way how you can retrieve the API key for your app.
//      static var `default`: String {
//        guard let filePath = Bundle.main.path(forResource: "GenerativeAI-Info", ofType: "plist")
//        else {
//          fatalError("Couldn't find file 'GenerativeAI-Info.plist'.")
//        }
//        let plist = NSDictionary(contentsOfFile: filePath)
//        guard let value = plist?.object(forKey: "GEMINI_API_KEY") as? String else {
//          fatalError("Couldn't find key 'GEMINI_API_KEY' in 'GenerativeAI-Info.plist'.")
//        }
//        if value.starts(with: "_") || value.isEmpty {
//          fatalError(
//            "Follow the instructions at https://ai.google.dev/tutorials/setup to get an API key."
//          )
//        }
//        return value
//      }
//    }
//    
////    func loadFacts(latitude: Double, longitude: Double) {
////        // Your existing code to load facts from an API
////    }
//    
//    func loadContent() async {
//        do {
//            print("here2")
//            let model = GenerativeModel(name: "gemini-pro", apiKey: APIKey.default)
//            let locationName = "Westmont, Chicago" // Example location name
//
//            let prompt = """
//            Give a detailed report on \(locationName) including very interesting historical facts, notable events, cultural significance, intriguing and obscure details, lesser-known aspects,  and hidden gems that most people might not know.
//                               provid intriguing and obscure details about the location that most people might not know. Everything must be things people do not know about the place. Please provide each fact with a concise title(must be captivating) and a more detailed description. Give me atleast 10 results. The results must be returned in a valid JSON. Please ensure all fields are properly quoted and the JSON is correctly formatted. Here is an example of how the JSON should look:
//            {
//              'location': '\(locationName)',
//              'facts': [
//                {
//                  'title': 'Title of Fact 1',
//                  'description': 'Detailed description of Fact 1',
//                  'imageUrl': 'https://example.com/path/to/image1.jpg'
//                },
//                {
//                  'title': 'Title of Fact 2',
//                  'description': 'Detailed description of Fact 2",
//                  'imageUrl': 'https://example.com/path/to/image2.jpg'
//                },
//                {
//                  'title': "Title of Fact 3',
//                  'description': 'Detailed description of Fact 3',
//                  'imageUrl': 'https://example.com/path/to/image3.jpg'
//                }
//                // Additional facts can be added in the same structure
//              ]
//            }
//            Each fact must be unique and informative, aimed at enlightening even the locals who think they know all there is about the place.
//            """
//            let response = try await model.generateContent(prompt)
//            
//            
//            if let text = response.text {
////                print(text) // Handle the response text
//                DispatchQueue.main.async {
//                        self.parseFactsFromResponse(text)
//                }
//                
//            }
//        } catch {
//            print("Error generating content: \(error)")
//        }
//    }
//    
//    func validateAndTrimJSON(_ responseText: String) -> String? {
//        guard let startIndex = responseText.firstIndex(of: "{"),
//              let endIndex = responseText.lastIndex(of: "}") else {
//            print("Invalid JSON: No JSON object found in the response.")
//            return nil
//        }
//
//        let range = startIndex...endIndex
//        let validJSONString = String(responseText[range])
//        return validJSONString
//    }
//    
//    private func parseFactsFromResponse(_ response: String) {
//        if let validJSON = validateAndTrimJSON(response) {
//            print(validJSON)
//            do {
//                let jsonData = Data(validJSON.utf8)
//                let responseStructure = try JSONDecoder().decode(ResponseStructure.self, from: jsonData)
//                DispatchQueue.main.async {
//                    self.facts = responseStructure.facts.map {
//                        Fact(title: $0.title, description: $0.description, imageUrl: $0.imageUrl)
//                    }
//                }
//            } catch {
//                print("Error parsing JSON: \(error)")
//            }
//        } else {
//            print("Failed to extract valid JSON.")
//        }
//    }
//
//    
//
//    
//    struct ResponseStructure: Codable {
//        let location: String
//        let facts: [Fact]
//    }
//    
//    
//}

    
//    private func parseFactsFromResponse(_ response: String) {
//        let pattern = #"""
//        "title"\s*:\s*"(.*?)",
//        "description"\s*:\s*"(.*?)",
//        "imageUrl"\s*:\s*"(.*?)"
//        """#
//
//
//        let regex = try! NSRegularExpression(pattern: pattern, options: [])
//        let results = regex.matches(in: response, options: [], range: NSRange(response.startIndex..., in: response))
//
//        DispatchQueue.main.async {
//            self.facts = results.map {
//                let titleRange = Range($0.range(at: 1), in: response)!
//                let descriptionRange = Range($0.range(at: 2), in: response)!
//                let imageUrlRange = Range($0.range(at: 3), in: response)!
//
//                return Fact(
//                    title: String(response[titleRange]),
//                    description: String(response[descriptionRange]),
//                    imageUrl: String(response[imageUrlRange])
//                )
//            }
//        }
    
//        if let response = validateAndTrimJSON(response) {
//            print("Valid JSON: \(response)")
//            do {
//                let jsonData = Data(response.utf8)
//                let responseStructure = try JSONDecoder().decode(ResponseStructure.self, from: jsonData)
//                DispatchQueue.main.async {
//                    print("here3")
//                    self.facts = responseStructure.facts.map {
//                        Fact(id: nil, title: $0.title, description: $0.description, imageUrl: $0.imageUrl)
//                    }
//                }
//            } catch {
//                print("Error parsing JSON: \(error)")
//            }
//        } else {
//            print("Failed to extract valid JSON.")
//        }
//
//
//    }
