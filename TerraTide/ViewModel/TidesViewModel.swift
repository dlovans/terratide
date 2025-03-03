//
//  TidesViewModel.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-19.
//

import Foundation
import FirebaseFirestore

class TidesViewModel: ObservableObject {
    @Published var availableTidesHaveLoaded: Bool = false
    @Published var activeTidesHaveLoaded: Bool = false
    @Published var availableTides: [Tide] = []
    @Published var activeTides: [Tide] = []
    
    private let tidesRepository = TidesRepository()
    private var availableTidesListener: ListenerRegistration? = nil
    private var activeTidesListener: ListenerRegistration? = nil
    
    /// Calls method in TidesRepository to fetch available tides and attach listener to app.
    /// - Parameter userLocation: User location with longitude and latitude.
    func attachAvailableTidesListener(for userLocation: Coordinate, adult: Bool, userId: String, blockedUsers: [String:String], blockedByUsers: [String]) {
        let newTidesListener = tidesRepository.attachAvailableTidesListener(for: userLocation, adult: adult, userId: userId, blockedUsers: blockedUsers, blockedByUsers: blockedByUsers) { [weak self] tides in
            guard let self else { return }
            if let tides {
                self.availableTides = tides
            } else {
                print("Failed to fetch available tides!")
                self.availableTides = []
            }
        }
        
        self.availableTidesListener = newTidesListener
        self.availableTidesHaveLoaded = true
    }
    
    /// Removes available tides listener and resets loading flag.
    func removeAvailableTidesListener() {
        self.availableTidesListener?.remove()
        self.availableTidesListener = nil
        self.availableTidesHaveLoaded = false
    }
    
    /// Calls method in TidesRepository to fetch active (joined) tides and attach listener to app.
    /// - Parameter userId: User ID of the user to fetch joined tides.
    func attachActiveTidesListener(userId: String) {
        let newTidesListener = tidesRepository.attachActiveTidesListener(userId: userId) { [weak self] tides in
            guard let self else { return }
            if let tides {
                self.activeTides = tides
            } else {
                print("Failed to fetch active tides!")
                self.activeTides = []
            }
        }
        
        self.activeTidesListener = newTidesListener
        self.activeTidesHaveLoaded = true
    }
    
    /// Removes active tides listener and resets loading flag.
    func removeActiveTidesListener() {
        self.activeTidesListener?.remove()
        self.activeTidesListener = nil
        self.activeTidesHaveLoaded = false
    }
}
