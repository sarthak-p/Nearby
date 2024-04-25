//
//  ContentView.swift
//  Nearby
//
//  Created by Sarthak Patipati on 4/16/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var factFetcher = FactFetcher()

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(factFetcher.facts) { fact in
                        NavigationLink(destination: FactDetailView(fact: fact)) {
                            VStack {
                                Image(systemName: "book.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(8)
                                    .foregroundColor(.white)
                                
                                Text(fact.title)
                                    .fontWeight(.semibold)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, minHeight: 150)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Historical Facts")
        }
        .onAppear {
            locationManager.start()
        }
        .onReceive(locationManager.$currentLocation) { location in
            guard let location = location else { return }
            factFetcher.loadFacts(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
}

// Detail view for a single fact
struct FactDetailView: View {
    var fact: Fact
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(fact.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(fact.description)
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle(fact.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Preview provider
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


