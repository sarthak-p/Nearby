//
//  NotificationManager.swift
//  Nearby
//
//  Created by Sai Samarth Patipati Umesh on 4/28/24.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var currentLocation: CLLocation?
    var factFetcher: FactFetcher?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // Set the desired accuracy
        locationManager.requestWhenInUseAuthorization() // Request appropriate authorization from the user
        locationManager.startUpdatingLocation() // Start updating location
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            if CLLocationManager.locationServicesEnabled() {
                locationManager.startUpdatingLocation()
            } else {
                print("Location services are not enabled")
            }
        case .restricted, .denied:
            print("Location access was restricted or denied.")
        @unknown default:
            print("Unknown authorization status")
        }
    }

    
    func startLocationUpdates() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        } else {
            print("Location services are not enabled")
        }
    }


    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) async {
        guard let newLocation = locations.last else { 
            print("No locations available")
            return }
        print("New location: \(newLocation)")
        DispatchQueue.main.async {
                self.currentLocation = newLocation
//                self.factFetcher?.updateLocation(newLocation)
            }
        
        Task {
               await factFetcher?.updateLocation(newLocation)
               // if you have any additional async functions to call, you can do so here
           }
        
//        currentLocation = newLocation // Update the current location
//        // Here you can add code to fetch new facts using newLocation if needed
//        await factFetcher?.loadContent(with: currentLocation)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let clError = error as? CLError {
            switch clError.code {
            case .locationUnknown:
                print("Location unknown, retrying")
                locationManager.startUpdatingLocation()
            case .denied:
                print("Access to location services denied by the user")
            case .network:
                print("Network-related error occurred while retrieving location")
            default:
                print("Other Core Location error: \(clError.localizedDescription)")
            }
        } else {
            print("Failed to find user's location: \(error.localizedDescription)")
        }
    }
}
