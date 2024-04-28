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

//import SwiftUI
//
//struct ContentView: View {
//    @ObservedObject var factFetcher = FactFetcher() // Observes changes to facts
//
//    let columns = [
//        GridItem(.adaptive(minimum: 150))
//    ]
//
//    var body: some View {
//        NavigationView {
//            ScrollView {
//                LazyVGrid(columns: columns, spacing: 20) {
//                    ForEach(factFetcher.facts) { fact in
//                        NavigationLink(destination: Text(fact.description)) { // Detail view
//                            VStack {
//                                AsyncImage(url: URL(string: fact.imageUrl)) { image in
//                                    image.resizable()
//                                        .aspectRatio(contentMode: .fill)
//                                        .frame(width: 100, height: 100)
//                                        .clipped()
//                                } placeholder: {
//                                    Color.gray
//                                }
//                                .frame(width: 100, height: 100)
//                                .cornerRadius(8)
//                                .padding()
//
//                                Text(fact.title)
//                                    .fontWeight(.semibold)
//                                    .multilineTextAlignment(.center)
//                                    .padding()
//                            }
//                            .frame(maxWidth: .infinity, minHeight: 150)
//                            .background(Color.gray.opacity(0.2))
//                            .cornerRadius(12)
//                        }
//                    }
//                }
//                .padding()
//            }
//            .navigationTitle("Nearby Historical Facts")
//        }
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}





//import SwiftUI
//
//struct ContentView: View {
//    @StateObject var factFetcher = FactFetcher() // Using StateObject for owning the object
//
//    var body: some View {
//        NavigationView {
//            List(factFetcher.facts) { fact in
//                VStack(alignment: .leading) {
//                    Text(fact.title)
//                        .font(.headline)
//                    Text(fact.description)
//                        .font(.subheadline)
//                }
//            }
//            .navigationTitle("Facts About the Place")
//            .onAppear {
//                Task {
//                    await factFetcher.loadContent()
//                }
//            }
//        }
//    }
//}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}


