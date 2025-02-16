//
//  LocationService.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-16.
//

import Foundation
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate, ObservableObject {
    @Published var locationAuthorized: CLAuthorizationStatus = .notDetermined
    @Published var locationServicesLoaded: Bool = false
    @Published var boundingBox: (latStart: Double, latEnd: Double, longStart: Double, longEnd: Double)? = nil
        
    private var queryTimer: Timer?
    private var manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        self.locationAuthorized = manager.authorizationStatus
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.requestLocation()
    }
    
    
    /// Periodically gets and updates user's location, with 1 minute 30 seconds interval.
    func startPeriodicLocationTask() {
        queryTimer?.invalidate()
        manager.requestLocation()
        queryTimer = Timer.scheduledTimer(withTimeInterval: 90, repeats: true) { [weak self] _ in
            self?.manager.requestLocation()
        }
    }
    
    /// Calculates a bounding box that is 20 square kms using user's position.
    /// - Parameter center: Coordination of the user with longitude and latitude.
    /// - Returns: A tuple representing a bounding box where the center is the user's position.
    func calculateBoundingBox(center: Coordinate) -> (latStart: Double, latEnd: Double, longStart: Double, longEnd: Double) {
        let distanceInMeters: Double = 20000.0 // 20KM

        
        let latDegreeLength = 111_000.0
        let latChange = distanceInMeters / latDegreeLength
        
        let lonDegreeLength = 111_000.0 * cos(center.latitude * .pi / 180.0)
        let lonChange = distanceInMeters / lonDegreeLength
        
        let latStart = center.latitude - latChange
        let latEnd = center.latitude + latChange
        let longStart = center.longitude - lonChange
        let longEnd = center.longitude + lonChange
        
        return (latStart, latEnd, longStart, longEnd)
    }
    
    /// Checks user permission for location service.
    func checkLocationAuthorization() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            locationAuthorized = manager.authorizationStatus
        case .authorizedWhenInUse, .authorizedAlways:
            locationAuthorized = manager.authorizationStatus
        @unknown default:
            locationAuthorized = .notDetermined
        }
    }
        
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let lastLocation = locations.last {
            let coordinate = Coordinate(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude)
            self.boundingBox = self.calculateBoundingBox(center: coordinate)
            if !locationServicesLoaded { locationServicesLoaded = true }
        }
        
    }
}
