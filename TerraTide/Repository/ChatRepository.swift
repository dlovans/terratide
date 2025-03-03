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
    /// - Parameters:
    ///   - boundingBox: Tuple representing a bounding box, calculated from a user's position.
    ///   - onUpdate: A closure that runs when fetching messages is completed.
    /// - Returns: Chat messages listener. Use to reset in ChatViewModel to avoid memory leaks.
    func attachGeoChatListener(for userLocation: Coordinate, adult: Bool, blockedByUsers: [String], blockedUsers: [String: String], onUpdate: @escaping ([Message]?) -> Void) -> ListenerRegistration? {
        let geoChatListener = db.collection("messages")
            .whereField("adult", isEqualTo: adult)
            .whereField("longStart", isLessThanOrEqualTo: userLocation.longitude)
            .whereField("longEnd", isGreaterThanOrEqualTo: userLocation.longitude)
            .whereField("latStart", isLessThanOrEqualTo: userLocation.latitude)
            .whereField("latEnd", isGreaterThanOrEqualTo: userLocation.latitude)
            .whereField("timestamp", isGreaterThanOrEqualTo: Date().addingTimeInterval(-(12 * 60 * 60)))
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
                
                let filteredMessages = snapshot.documents.filter { message in
                    let messageCreatorId = message.data()["byUserId"] as? String ?? ""
                    return !blockedByUsers.contains(messageCreatorId) && !blockedUsers.keys.contains(messageCreatorId)
                }
                
                let geoMessages: [Message] = filteredMessages.compactMap { message in
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
    
    /// Create a geo message document in the database.
    /// - Parameters:
    ///   - text: Message content.
    ///   - sender: Username of sender.
    ///   - userId: User ID of sender.
    ///   - boundingBox: Geospatial bounding box for this message.
    /// - Returns: Status of message operation.
    func createGeoMessage(with text: String, by sender: String, with userId: String, boundingBox: BoundingBox?, adult: Bool) async -> MessageStatus {
        if text.isEmpty {
            return .emptyMessage
        }
        
        guard let boundingBox else { return .invalidLocation }
        
        do {
            try await db.collection("messages").addDocument(data: [
                "text": text,
                "sender": sender,
                "byUserId": userId,
                "timestamp": Date(),
                "longStart": boundingBox.longStart,
                "longEnd": boundingBox.longEnd,
                "latStart": boundingBox.latStart,
                "latEnd": boundingBox.latEnd,
                "adult": adult
            ])
            return .sent
        } catch {
            print("An error occurred while creating a geo message: \(error)")
            return .failedToCreate
        }
    }
    
    /// Fetches tide-based chat messages.
    /// - Parameters:
    ///   - tideId: ID of Tide with `messages` subcollection.
    ///   - onUpdate: A closure that runs when fetching messages is completed.
    /// - Returns: Chat messages listener. Use to reset in ChatViewModel to avoid memory leaks.
    func attachTideChatListener(for tideId: String, blockedByUsers: [String], blockedUsers: [String: String], onUpdate: @escaping ([Message]?) -> Void) -> ListenerRegistration? {
        let tideChatListener = db.collection("tides").document(tideId).collection("messages")
            .order(by: "timestamp")
            .limit(to: 100)
            .addSnapshotListener { querySnapshot, error in
                if let error {
                    print("An error occurred while listening for tide chat: \(error)")
                    onUpdate(nil)
                }
                
                guard let snapshot = querySnapshot else {
                    print("Error fetching messages for tide chat: \(error!)")
                    onUpdate(nil)
                    return
                }
                
                if snapshot.isEmpty {
                    onUpdate([])
                    return
                }
                
                let filteredMessages = snapshot.documents.filter { message in
                    let messageCreatorId = message.data()["byUserId"] as? String ?? ""
                    return !blockedByUsers.contains(messageCreatorId) && !blockedUsers.keys.contains(messageCreatorId)
                }
                
                let tideMessages: [Message] = filteredMessages.compactMap { message in
                    do {
                        return try message.data(as: Message.self)
                    } catch {
                        print("Error decoding message data: \(error)")
                        return nil
                    }
                }
                onUpdate(tideMessages)
            }
        
        return tideChatListener
    }
    
    /// Create a Tide message document in the database.
    /// - Parameters:
    ///   - tideId: ID of Tide with `messages` subcollection.
    ///   - text: Message content.
    ///   - sender: Username of sender.
    ///   - userId: User ID of sender.
    /// - Returns: Status of message operation.
    func createTideMessage(tideId: String, with text: String, by sender: String, with userId: String) async -> MessageStatus {
        if text.isEmpty {
            print("Message is empty.")
            return .emptyMessage
        }
        
        if tideId.isEmpty || sender.isEmpty || userId.isEmpty {
            print("Invalid data provided.")
            return .invalidData
        }
                
        do {
            try await db.collection("tides").document(tideId).collection("messages").addDocument(data: [
                "text": text,
                "sender": sender,
                "byUserId": userId,
                "timestamp": Date()
            ])
            
            return .sent
        } catch {
            print("An error occurred while creating a Tide message: \(error)")
            return .failedToCreate
        }
    }
}
