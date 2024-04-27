//
//  ContentView.swift
//  Nearby
//
//  Created by Sarthak Patipati on 4/16/24.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var factFetcher = FactFetcher() // For simplicity, using ObservedObject here

    let columns = [
        GridItem(.adaptive(minimum: 150))
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(factFetcher.facts) { fact in
                        NavigationLink(destination: Text(fact.description)) { // Placeholder for detail view
                            VStack {
                                Image(systemName: "book.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 100)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(8)
                                
                                Text(fact.title)
                                    .fontWeight(.semibold)
                                    .multilineTextAlignment(.center)
                                    .padding()
                            }
                            .frame(maxWidth: .infinity, minHeight: 150)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Nearby")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(factFetcher: FactFetcher())
    }
}






