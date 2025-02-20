//
//  TidesRepository.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-19.
//

import Foundation
import FirebaseFirestore

class TidesRepository {
    let db = Firestore.firestore()
    
    /// Fetches Tides around the user's location and attaches a listener.
    /// - Parameters:
    ///   - userLocation: Location of the user.
    ///   - onUpdate: A closure that is executed when the fetching and attaching the listener is completed.
    /// - Returns: A listener, listening on the `tides` collection documents.
    func attachTidesListener(for userLocation: Coordinate, userId: String, onUpdate: @escaping ([Tide]?) -> Void) -> ListenerRegistration? {
        let listener = db.collection("tides")
            .whereField("active", isEqualTo: true)
            .whereField("longStart", isLessThanOrEqualTo: userLocation.longitude)
            .whereField("longEnd", isGreaterThanOrEqualTo: userLocation.longitude)
            .whereField("latStart", isLessThanOrEqualTo: userLocation.latitude)
            .whereField("latEnd", isGreaterThanOrEqualTo: userLocation.latitude)
            .order(by: "participantCount", descending: true)
            .addSnapshotListener { querySnapshot, error in
                if let error {
                    print("Failed to fetch Tide documents: \(error.localizedDescription)")
                    onUpdate(nil)
                    return
                }
                
                guard let querySnapshot, !querySnapshot.isEmpty else {
                    print("No documents fetched.")
                    onUpdate(nil)
                    return
                }
                
                let filteredTides = querySnapshot.documents.filter { document in
                    let members = document.data()["memberIds"] as? [String: String] ?? [:]
                    let participantCount = document.data()["participantCount"] as? Int ?? 0
                    let maxParticipants = document.data()["maxParticipants"] as? Int ?? 0
                    return !members.keys.contains(userId) && participantCount < maxParticipants
                }
                let tides: [Tide] = filteredTides.compactMap { tide in
                    do {
                        return try tide.data(as: Tide.self)
                    } catch {
                        print("Error decoding Tide data, \(error)")
                        return nil
                    }
                }
                onUpdate(tides)
            }
        
        return listener
    }
}
