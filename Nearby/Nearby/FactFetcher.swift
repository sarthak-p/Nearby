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
    private var currentLocationDescription: String?
    private var locationManager = LocationManager.shared
    private var retryCount = 0
    private var postal: String?
    private let maxRetries = 5 // Maximum number of retries
    
    init() {
            // Setting up the location manager to fetch reverse geocoded location
            LocationManager.shared.getCurrentReverseGeoCodedLocation { [weak self] (location, placemark, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error retrieving location: \(error.localizedDescription)")
                    return
                }

                guard let placemark = placemark else {
                    print("No placemark available.")
                    return
                }

                // Constructing a description from the placemark
                self.currentLocationDescription = [
                    placemark.subLocality,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.country
                ].compactMap { $0 }.joined(separator: ", ")
                
//                print("Latitude: \(location.coordinate.latitude) Longitude: \(location.coordinate.longitude)")
                print("Location identified as: \(self.currentLocationDescription ?? "Unknown")")
                Task {
                    await self.loadContent()
                }
            }
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
        
        
        func loadContent() async{
            if let locationDescription = currentLocationDescription {
                //                isLoading = true
                //                let locationName = "\(location.coordinate.latitude), \(location.coordinate.longitude)"
                // Proceed with using locationName
                
                isLoading = true
                //            let locationName = "\(location.coordinate.latitude), \(location.coordinate.longitude)"
                //            let locationName = location
                //              let locationName = location
                print("Loading content for location: \(locationDescription)")
                
                
                do {
                    let model = GenerativeModel(name: "gemini-pro", apiKey: APIKey.default)
                    //                self.locationName = "Westmont, Chicago" // Example location name
                    
                    
                    let prompt = """
                Give a detailed report on \(locationDescription) including very interesting historical facts, notable events, cultural significance, intriguing and obscure details, lesser-known aspects, and hidden gems that most people might not know. Please provide each fact with a concise title (must be captivating), a more detailed description (around 150 words) and an image to accompany the fact. Get the image url from images.google.com and it should usable in swift and a jpg file. Provide an address for the fact, event, places in latitude and longitude. Provide the official webpage for the fact, event, places if one exists. Do not give wikipedia pages for the URLs. Give me at least 10 results. The results must be returned in a valid JSON format with properly quoted fields. Here is an example of how the JSON should look:
                {
                  "location": "\(locationDescription)",
                  "facts": [
                    {
                      "title": "Title of Fact 1",
                      "description": "Detailed description of Fact 1",
                      "imageUrl": "https://example.com/path/to/image1.jpg"
                      "url": "https://example.com"
                      "latitude of where the fact is if it's a place": 40.712776
                      "longitude of where the fact is if it's a place": -74.005974
                    },
                    {
                      "title": "Title of Fact 2",
                      "description": "Detailed description of Fact 2",
                      "imageUrl": "https://example.com/path/to/image2.jpg"
                      "url": "https://example.com"
                      "latitude of where the fact is if it's a place": 40.712776
                      "longitude of where the fact is if it's a place": -74.005974
                    },
                    {
                      "title": "Title of Fact 3",
                      "description": "Detailed description of Fact 3",
                      "imageUrl": "https://example.com/path/to/image3.jpg"
                      "url": "https://example.com"
                      "latitude of where the fact is if it's a place": 40.712776
                      "longitude of place of where the fact is if it's a place": -74.005974
                    }
                    // Additional facts can be added in the same structure
                  ]
                }
                Return in exactly the above format. Do not add anything extra before or after. The facts should be things even locals wouldn't know. It should help tourists learn more about the location.
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
                                            self.isLoading = false
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
                    self.isLoading = false
                }
            } else {
                print("Location is not set")
            }
        }
        
       func retryLoadingContent() async {
            if retryCount < maxRetries {
                retryCount += 1
                print("Retrying... Attempt \(retryCount)")
                if let locationDescription = currentLocationDescription {
                    await loadContent()
                } else {
                    print("No location available for retry")
                }
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
    
    
    
