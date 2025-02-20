//
//  SingleTideViewModel.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-16.
//

import Foundation
import FirebaseFirestore

class SingleTideViewModel: ObservableObject {
    let tideRepository = SingleTideRepository()
    @Published var tideHasLoaded: Bool = false
    @Published var tideChatHasLoaded: Bool = false
    @Published var tide: Tide? = nil
    @Published var tideListener: ListenerRegistration? = nil
    
    private var listener: ListenerRegistration? = nil
    
    /// Calls method in TideRepository that creates a Tide in Firestore.
    /// - Parameters:
    ///   - byUserID: UserID of Tide creator.
    ///   - byUsername: Username of Tide creator.
    ///   - tideTitle: Title of Tide.
    ///   - tideDescription: Tide description.
    ///   - tideGroupSize: Max number of participants of Tide.
    /// - Returns: Tide creation status. Refer to `TideCreationStatus` in `Utils` directory.
    func createTide(
        byUserID: String,
        byUsername: String,
        tideTitle: String,
        tideDescription: String,
        maxParticipants: Int,
        boundingBox: BoundingBox
    ) async -> TideCreationStatus {
        return await tideRepository.createTide(byUserID: byUserID, byUsername: byUsername, tideTitle: tideTitle, tideDescription: tideDescription, maxParticipants: maxParticipants, boundingBox: boundingBox)
    }
    
    /// Attaches a Tide listener.
    /// - Parameter tideId: ID of Tide to fetch and listen to.
    func attachTideListener(tideId: String) { // TODO: Consider returning status if Tide fails to load.
        let newTideListener = tideRepository.attachTideListener(tideId: tideId) { [weak self] tide in
            if let tide {
                self?.tide = tide
                
            } else {
                print("Something went wrong while fetching Tide data.")
                self?.tide = nil
            }
            self?.tideHasLoaded = true
        }
        
        self.tideListener?.remove()
        self.tideListener = newTideListener
    }
    
    /// Destroys Tide listener.
    func removeTideListener() {
        self.tideHasLoaded = false
        self.tideListener?.remove()
        self.tideListener = nil
        self.tide = nil
    }
}
