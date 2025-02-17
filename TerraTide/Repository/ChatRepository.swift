//
//  ChatRepository.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-16.
//

import Foundation
import FirebaseFirestore

class ChatRepository {
    let db = Firestore.firestore()
    
    /// Fetches geo-based chat messages.
    /// - Note: Do not confuse with Tide-specific chat messages! Tide-specific chat messages are found in TideRepository.
    /// - Parameters:
    ///   - boundingBox: Tuple representing a bounding box, calculated from a user's position.
    ///   - onUpdate: A closure that runs when fetching messages is completed.
    /// - Returns: Chat messages listener. Use to reset in ChatViewModel to avoid memory leaks.
    func attachChatListener(for userLocation: Coordinate, onUpdate: @escaping ([Message]?) -> Void) -> ListenerRegistration? {
        let geoChatListener = db.collection("messages")
            .whereField("longStart", isLessThanOrEqualTo: userLocation.longitude)
            .whereField("longEnd", isGreaterThanOrEqualTo: userLocation.longitude)
            .whereField("latStart", isLessThanOrEqualTo: userLocation.latitude)
            .whereField("latEnd", isGreaterThanOrEqualTo: userLocation.latitude)
            .order(by: "timestamp")
            .limit(to: 50)
            .addSnapshotListener { querySnapshot, error in
                if let error {
                    print("An error occurred while listening for geo chats: \(error)")
                    onUpdate(nil)
                }
                
                guard let snapshot = querySnapshot else {
                    print("Error fetching messages for geo chat: \(error!)")
                    onUpdate(nil)
                    return
                }
                
                if snapshot.isEmpty {
                    onUpdate([])
                    return
                }
                
                let geoMessages: [Message] = snapshot.documents.compactMap { message in
                    do {
                        return try message.data(as: Message.self)
                    } catch {
                        print("Error decoding message data: \(error)")
                        return nil
                    }
                }
                
                onUpdate(geoMessages)
            }
        
        return geoChatListener
    }
}
