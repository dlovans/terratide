//
//  TideViewModel.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-16.
//

import Foundation

class TideViewModel: ObservableObject {
    let tideRepository = TideRepository()
    
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
        tideGroupSize: Int
    ) async -> TideCreationStatus {
        return await tideRepository.createTide(byUserID: byUserID, byUsername: byUsername, tideTitle: tideTitle, tideDescription: tideDescription, tideGroupSize: tideGroupSize)
    }
}
