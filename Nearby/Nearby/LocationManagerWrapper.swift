//
//  LocationManagerWrapper.swift
//  Nearby
//
//  Created by Sarthak Patipati on 5/1/24.
//

import Foundation
import Combine
import CoreLocation

class LocationManagerWrapper: NSObject, ObservableObject {
    static let shared = LocationManagerWrapper()
    
    @Published var lastLocation: CLLocation?
    private let locationManager = LocationManager.shared
    
    override init() {
        super.init()
        setupNotifications()
    }
    
    private func setupNotifications() {
        // Assuming LocationManager posts notifications when location updates
        NotificationCenter.default.addObserver(self, selector: #selector(locationUpdated(_:)), name: NSNotification.Name("LocationUpdated"), object: nil)
    }
    
    @objc private func locationUpdated(_ notification: Notification) {
        if let location = notification.userInfo?["location"] as? CLLocation {
            DispatchQueue.main.async {
                self.lastLocation = location
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

