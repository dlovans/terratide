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
    func attachTidesListener(for userLocation: Coordinate) {
        let newTidesListener = tidesRepository.attachTidesListener(for: userLocation) { tides in
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
}
