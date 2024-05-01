import SwiftUI
import Kingfisher
import MapKit

struct ContentView: View {
    @StateObject private var factFetcher = FactFetcher()
    @ObservedObject private var locationManager = LocationManagerWrapper.shared

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Display the last known location
                    if let location = locationManager.lastLocation {
                        Text("Your current location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.gray.opacity(0.5))
                            .cornerRadius(8)
                            .padding(.horizontal, 20) // Ensure padding is uniform
                    }

                    if factFetcher.isLoading {
                        VStack {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                                .scaleEffect(1.5)
                            Text("Loading facts...")
                                .font(.headline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity) // Ensure loader uses full width
                    } else {
                        ForEach(factFetcher.facts) { fact in
                            NavigationLink(destination: DetailView(fact: fact)) {
                                FactTile(fact: fact)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .frame(maxWidth: .infinity) // Ensure content uses full width
            }
            .navigationTitle("Nearby")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
        .accentColor(.white)
    }
}


struct FactTile: View {
    var fact: Fact

    var body: some View {
        VStack {
            KFImage(URL(string: fact.imageUrl))
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 200)
                .cornerRadius(12)
                .padding(.bottom, 5)  // This correctly applies padding below the image

            Text(fact.title)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding(.horizontal)
                .padding(.bottom, 2)  // Properly formats padding below the title

            Text(fact.description)
                .font(.caption)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)  // Adds horizontal padding to the description
                .padding(.bottom, 5)   // Adds space below the description
        }
        .frame(maxWidth: .infinity)  // Ensures the content takes full width available
        .background(Color.gray.opacity(0.2))
        .cornerRadius(15)
        .shadow(radius: 10)
        .padding(.horizontal, 10)  // Adjusts padding around the entire tile for better alignment
    }
}


struct DetailView: View {
    var fact: Fact
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Description: ")
                Text(fact.description)
                    .padding()
                
                MapView(coordinate: CLLocationCoordinate2D(latitude: fact.latitude, longitude: fact.longitude))
                    .frame(height: 300)
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                
                Link("Learn More", destination: URL(string: fact.url)!)
                    .padding()
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
