//
//  LocationManager.swift
//  Nearby
//
//  Created by Sai Samarth Patipati Umesh on 4/22/24.
//

import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?

    override init() {
        super.init()
        locationManager.delegate = self
        // Set the desired accuracy of the location data
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        // Ask for the user's permission to access location data
        locationManager.requestWhenInUseAuthorization()
    }

    func start() {
        // Start updating the location
        locationManager.startUpdatingLocation()
    }
    
    func stop() {
        // Stop updating the location
        locationManager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate Methods

    // This method is called when the location manager has new location data
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // We're interested in the last location, which is the most recent
        if let location = locations.last {
            // Update the published currentLocation property
            currentLocation = location
        }
    }
    
    // This method is called when there's an error obtaining the location
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle error, e.g., by printing it to the console
        print("Error obtaining location: \(error)")
    }

    // This method is called when the authorization status changes
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Check the authorization status and react accordingly
        switch manager.authorizationStatus {
        case .notDetermined, .restricted, .denied:
            // Location access was denied or restricted
            break
        case .authorizedAlways, .authorizedWhenInUse:
            // Start location updates if the app is authorized
            start()
        default:
            break
        }
    }
}
