//
//  TideRepository.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-16.
//

import Foundation
import FirebaseFirestore

class TideRepository {
    let db = Firestore.firestore()
    
    /// Creates a Tide document in Firestore.
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
        if byUserID.isEmpty || byUsername.isEmpty {
            return .missingCredentials
        }
        
        if tideTitle.isEmpty || tideDescription.isEmpty || tideGroupSize < 2 || tideGroupSize > 10000 {
            return .invalidData
        }
        
        do {
            let result = try await db.collection("tides").addDocument(data: [
                "byUserId": byUserID,
                "byUsername": byUsername,
                "tideTitle": tideTitle,
                "tideDescription": tideDescription,
                "tideGroupSize": tideGroupSize,
                "createdAt": Timestamp(date: Date()),
                "memberIds": [byUserID]
            ])
            
            if result.documentID.isEmpty {
                print("Tide created but Document ID was empty when creating a Tide!")
                return .missingTideId
            }
            
            return .created(tideId: result.documentID)
        } catch {
            print("Failed to create a Tide")
            return .failed
        }
    }
}
