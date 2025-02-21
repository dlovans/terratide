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
                "primeFordeletionDate": Timestamp(date: Date().addingTimeInterval(24 * 60 * 60)),
                "members": [byUserID: byUsername],
                "longStart": boundingBox.longStart,
                "longEnd": boundingBox.longEnd,
                "latStart": boundingBox.latStart,
                "latEnd": boundingBox.latEnd,
                "active": true, // TODO: Write cloud function making this Tide invisible after expiryDate
                "primedForDeletion": false, // TODO: Write cloud function priming this Tide for deletion after deletionDate
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
    
    /// Joins a Tide.
    /// - Parameters:
    ///   - tideId: ID of the Tide to join.
    ///   - userId: ID of the user attempting to join Tide.
    ///   - username: Username of the user attempting to join Tide.
    /// - Returns: Status of join attempt.
    func joinTide(tideId: String, userId: String, username: String) async -> JoinTideStatus {
        if tideId.isEmpty {
            print("Tide ID argument is empty when attempting to join Tide.")
            return .invalidTide
        }
        
        do {
            let snapshot = try await db.collection("tides").document(tideId).getDocument()
            
            guard let data = snapshot.data(), snapshot.exists else {
                print("Failed to join Tide. No data found in snapshot.")
                return .noDocument
            }
            let members = data["members"] as? [String: String] ?? [:]
            
            if members.keys.contains(userId) {
                print("User is already a member of Tide.")
                return .alreadyJoined
            }
            
            let participantCount = data["participantCount"] as? Int ?? 0
            let maxParticipants = data["maxParticipants"] as? Int ?? 0
            if participantCount >= maxParticipants || maxParticipants < 1 {
                print("Tide is full! Could not join.")
                return .full
            } else {
                try await db.collection("tides").document(tideId).updateData([
                    "participantCount": FieldValue.increment(Int64(1)),
                    "members.\(userId)": username,
                    "memberIds": FieldValue.arrayUnion([userId])
                ])
            }
            return .joined
            
        } catch {
            print("Failed to join Tide. Error: \(error)")
            return .failed
        }
    }
    
    /// Leaves a Tide.
    /// - Parameters:
    ///   - tideId: ID of the Tide the user is attempting to leave.
    ///   - userId: ID of the user attempting to leave a Tide.
    /// - Returns: Status of attempt to leave a Tide.
    func leaveTide(tideId: String, userId: String) async -> LeaveTideStatus {
        if tideId.isEmpty || userId.isEmpty {
            print("Tide ID or user ID cannot be empty. Failed to leave.")
            return .invalidData
        }
        do {
            let tide = try await db.collection("tides").document(tideId).getDocument()
            if !tide.exists {
                print("Could not find Tide.")
                return .noDocument
            }
            
            let memberIds = tide.data()?["memberIds"] as? [String] ?? []
            if !memberIds.contains(userId) {
                print("User is not a member of Tide.")
                return .notMember
            }
            
            try await db.collection("tides").document(tideId).updateData([
                "participantCount": FieldValue.increment(Int64(-1)),
                "members.\(userId)": FieldValue.delete(),
                "memberIds": FieldValue.arrayRemove([userId])
            ])
            
            return .left
        } catch {
            print("Failed to leave Tide. Error: \(error)")
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
