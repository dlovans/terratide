//
//  TidesViewModel.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-19.
//

import Foundation
import FirebaseFirestore

class TidesViewModel: ObservableObject {
    @Published var tidesHaveLoaded: Bool = false
    @Published var tides: [Tide] = []
    
    private let tidesRepository = TidesRepository()
    private var tidesListener: ListenerRegistration? = nil
    
    /// Call method in TidesRepository to fetch tides and attach listener to app.
    /// - Parameter userLocation: User location with longitude and latitude.
    func attachAvailableTidesListener(for userLocation: Coordinate, userId: String) {
        let newTidesListener = tidesRepository.attachAvailableTidesListener(for: userLocation, userId: userId) { tides in
            if let tides {
                self.tides = tides
            } else {
                print("Failed to fetch available tides!")
                self.tides = []
            }
        }
        self.tidesListener = newTidesListener
        self.tidesHaveLoaded = true
    }
    
    /// Removes available tides listener and resets loading flag.
    func removeAvailableTidesListener() {
        self.tidesListener?.remove()
        self.tidesListener = nil
        self.tidesHaveLoaded = false
    }
}
