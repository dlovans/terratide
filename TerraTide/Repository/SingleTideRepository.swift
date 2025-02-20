//
//  SingleTideRepository.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-16.
//

import Foundation
import FirebaseFirestore

class SingleTideRepository {
    let db = Firestore.firestore()
    
    /// Creates a Tide document in Firestore.
    /// - Parameters:
    ///   - byUserID: UserID of Tide creator.
    ///   - byUsername: Username of Tide creator.
    ///   - tideTitle: Title of Tide.
    ///   - tideDescription: Tide description.
    ///   - tideGroupSize: Max number of participants of Tide.
    ///   - boundingBox: A square calculated from the center which is the user's location.
    /// - Returns: Tide creation status. Refer to `TideCreationStatus` in `Utils` directory.
    func createTide(
        byUserID: String,
        byUsername: String,
        tideTitle: String,
        tideDescription: String,
        maxParticipants: Int,
        boundingBox: BoundingBox
    ) async -> TideCreationStatus {
        if byUserID.isEmpty || byUsername.isEmpty {
            return .missingCredentials
        }
        
        if tideTitle.isEmpty || tideDescription.isEmpty || maxParticipants < 2 || maxParticipants > 10000 {
            return .invalidData
        }
        
        do {
            let result = try await db.collection("tides").addDocument(data: [
                "creatorId": byUserID,
                "creatorUsername": byUsername,
                "title": tideTitle,
                "description": tideDescription,
                "participantCount": 1,
                "maxParticipants": maxParticipants,
                "expiryDate": Timestamp(date: Date().addingTimeInterval(2 * 60 * 60)),
                "memberIds": [byUserID: byUsername],
                "longStart": boundingBox.longStart,
                "longEnd": boundingBox.longEnd,
                "latStart": boundingBox.latStart,
                "latEnd": boundingBox.latEnd,
                "active": true
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
    
    /// Fetches a Tide and attaches a document listener.
    /// - Parameters:
    ///   - tideId: ID of Tide to fetch.
    ///   - onUpdate: A closure that is called when a Tide document is fetched or the document is updated in the database.
    /// - Returns: A Tide document listener. Use to reset listener in TideViewModel to avoid memory leaks.
    func attachTideListener(tideId: String, onUpdate: @escaping(Tide?) -> Void) -> ListenerRegistration? {
        if tideId.isEmpty {
            onUpdate(nil)
            return nil
        }
        
        let listener = db.collection("tides").document(tideId).addSnapshotListener { documentSnapshot, error in
            if let error {
                print("Failed to fetch single Tide document.\(error.localizedDescription)")
                onUpdate(nil)
                return
            }
            
            guard let document = documentSnapshot, document.exists else {
                print("Tide document does not exist.")
                onUpdate(nil)
                return
            }
            
            do {
                let tide = try document.data(as: Tide.self)
                onUpdate(tide)
            } catch {
                print("Failed to convert document to Tide object.")
                onUpdate(nil)
            }
        }
        return listener
    }
}
