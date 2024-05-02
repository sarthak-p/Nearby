import SwiftUI
import MapKit

extension Color {
    static let customDarkBrown = Color(red: 56 / 255, green: 21 / 255, blue: 14 / 255)
    static let customCream = Color(red: 237 / 255, green: 230 / 255, blue: 211 / 255)
    static let customOliveGreen = Color(red: 92 / 255, green: 112 / 255, blue: 77 / 255)
    static let customRedBrown = Color(red: 179 / 255, green: 82 / 255, blue: 57 / 255)
    static let customDarkRed = Color(red: 166 / 255, green: 62 / 255, blue: 38 / 255)
}

struct ContentView: View {
    @StateObject private var factFetcher = FactFetcher()
    @ObservedObject private var locationManager = LocationManagerWrapper.shared

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    headerView
                    displayLocation
                    if factFetcher.isLoading {
                        loadingView
                    } else {
                        factList
                    }
                }
                .frame(maxWidth: .infinity)
                .background(Color.customCream) // Using custom color
            }
            .navigationTitle("Nearby")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.customDarkBrown.edgesIgnoringSafeArea(.all))
        }
        .accentColor(Color.customRedBrown)
    }

    var headerView: some View {
        VStack {
            Text("Nearby")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(Color.customDarkRed)
                .frame(maxWidth: .infinity, alignment: .center)
            Text("Check out the facts near you!")
                .font(.subheadline)
                .foregroundColor(Color.customOliveGreen)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
    }

    var displayLocation: some View {
        Group {
            if let location = locationManager.lastLocation {
                Text("Your current location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                    .font(.caption)
                    .foregroundColor(Color.customCream)
                    .padding()
                    .background(Color.customDarkBrown.opacity(0.8))
                    .cornerRadius(8)
                    .padding(.horizontal, 20)
            }
        }
    }

    var loadingView: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color.customRedBrown))
                .scaleEffect(1.5)
            Text("Loading Facts...")
                .font(.headline)
                .foregroundColor(Color.customOliveGreen)
        }
        .frame(maxWidth: .infinity)
    }

    var factList: some View {
        ForEach(factFetcher.facts) { fact in
            NavigationLink(destination: DetailView(fact: fact)) {
                FactTile(fact: fact)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

struct FactTile: View {
    var fact: Fact

    var body: some View {
        Text(fact.title)
            .fontWeight(.semibold)
            .multilineTextAlignment(.center)
            .foregroundColor(.white)
            .font(.title3)
            .padding()
            .frame(width: 280, height: 280)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white, lineWidth: 1) // Adding border
            )
            .shadow(radius: 10)
            .padding(.horizontal, 10)
    }
}

struct DetailView: View {
    var fact: Fact

    var body: some View {
        ScrollView {
            VStack {
                Text(fact.title)
                    .bold()
                    .font(.title)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)

                Text(fact.description)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)

                Spacer().frame(height: 20) // Additional space

                MapView(coordinate: CLLocationCoordinate2D(latitude: fact.latitude, longitude: fact.longitude))
                    .frame(width: 300, height: 300) // Reduced map size
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.gray, lineWidth: 1)
                    )

                Spacer().frame(height: 20) // Additional space

                Link("Learn More", destination: URL(string: fact.url)!)
                    .foregroundColor(.blue)
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle(fact.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.black)
        .foregroundColor(.white)
    }
}

struct MapView: View {
    var coordinate: CLLocationCoordinate2D
    @State private var region: MKCoordinateRegion

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        _region = State(initialValue: MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
    }

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: [MapAnnotationItem(coordinate: coordinate)]) { item in
            MapAnnotation(coordinate: item.coordinate) {
                Button(action: {
                    self.openMaps(coordinate: item.coordinate)
                }) {
                    Image(systemName: "mappin.circle.fill")
                        .font(.title)
                        .foregroundColor(.red)
                        .padding()
                }
            }
        }
    }

    private func openMaps(coordinate: CLLocationCoordinate2D) {
        let placemark = MKPlacemark(coordinate: coordinate, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Destination"
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
}

struct MapAnnotationItem: Identifiable {
    let id = UUID()
    var coordinate: CLLocationCoordinate2D
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
