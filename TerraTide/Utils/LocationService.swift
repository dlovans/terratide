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
    @Published var boundingBox: BoundingBox? = nil
    @Published var userLocation: Coordinate? = nil
        
    private var queryTimer: Timer?
    private var manager = CLLocationManager()
    
    override init() {
        super.init()
        manager.delegate = self
        self.locationAuthorized = manager.authorizationStatus
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    
    /// Periodically gets and updates user's location, with 1 minute 30 seconds interval.
    func startPeriodicLocationTask() {
        queryTimer?.invalidate()
        queryTimer = nil
        manager.requestLocation()
        queryTimer = Timer.scheduledTimer(withTimeInterval: 90, repeats: true) { [weak self] _ in
            self?.manager.requestLocation()
        }
    }
    
    func stopPeriodicLocationTask() {
        queryTimer?.invalidate()
        queryTimer = nil
        locationServicesLoaded = false
    }
    
    /// Calculates a bounding box that is 20 square kms using user's position.
    /// - Parameter center: Coordination of the user with longitude and latitude.
    /// - Returns: A bounding box calculated from the user's location becoming the center of this box.
    func calculateBoundingBox(center: Coordinate) -> BoundingBox {
        let distanceInMeters: Double = 20000.0 // 20KM

        
        let latDegreeLength = 111_000.0
        let latChange = distanceInMeters / latDegreeLength
        
        let lonDegreeLength = 111_000.0 * cos(center.latitude * .pi / 180.0)
        let lonChange = distanceInMeters / lonDegreeLength
        
        
        return BoundingBox(
            longStart: center.longitude - lonChange,
            longEnd: center.longitude + lonChange,
            latStart: center.latitude - latChange,
            latEnd: center.latitude + latChange
        )
        
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
            self.userLocation = Coordinate(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude)
            self.boundingBox = self.calculateBoundingBox(center: self.userLocation!)
            if !locationServicesLoaded { locationServicesLoaded = true }
        }
        
    }
}
