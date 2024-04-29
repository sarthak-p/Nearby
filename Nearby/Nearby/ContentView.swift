//
//  ContentView.swift
//  Nearby
//
//  Created by Sarthak Patipati on 4/16/24.
//

import SwiftUI
import Kingfisher

struct ContentView: View {
    @ObservedObject var factFetcher = FactFetcher()

    let columns = [
        GridItem(.adaptive(minimum: 150))
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                if factFetcher.isLoading {
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .scaleEffect(1.5)
                        Text("Loading facts...")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                } else {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(factFetcher.facts) { fact in
                            NavigationLink(destination: Text(fact.description)) {
                                FactTile(fact: fact)
                            }
                        }
                    }
                }
            }
            .navigationTitle(factFetcher.locationName)
            .navigationBarTitleDisplayMode(.inline)
            .padding()
        }
    }
}

struct FactTile: View {
  var fact: Fact

  var body: some View {
    VStack {
      KFImage(URL(string: fact.imageUrl))
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: 100, height: 100)
        .clipped()
        .cornerRadius(8)
//        .placeholder { url in
//          KFImage(url: URL(string: "your_placeholder_image_url"))
//            .resizable()
//            .aspectRatio(contentMode: .fill)
//            .frame(width: 100, height: 100)
//            .clipped()
//        }

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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
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


