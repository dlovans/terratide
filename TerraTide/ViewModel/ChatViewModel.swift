//
//  ChatViewModel.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-16.
//

import Foundation
import FirebaseFirestore

class ChatViewModel: ObservableObject {
    @Published var geoChatHasLoaded: Bool = false
    @Published var geoMessages: [Message] = []
    @Published var tideChatHasLoaded: Bool = false
    @Published var tideMessages: [Message] = []
    
    private var chatRepositoy = ChatRepository()
    private var geoChatListener: ListenerRegistration? = nil
    private var tideChatListener: ListenerRegistration? = nil
    
    /// Attaches a listener to geo chat messages.
    /// - Parameter userLocation: User location with longitude and latitude values.
    func attachGeoChatListener(userLocation: Coordinate, adult: Bool, blockedByUsers: [String], blockedUsers: [String: String]) {
        let newGeoChatListener = chatRepositoy.attachGeoChatListener(for: userLocation, adult: adult, blockedByUsers: blockedByUsers, blockedUsers: blockedUsers) { [weak self] messages in
            if let messages {
                self?.geoMessages = messages
            } else {
                print("Something went wrong while fetching geo messages")
                self?.geoMessages = []
            }
            self?.geoChatHasLoaded = true
        }
        self.geoChatListener?.remove()
        self.geoChatListener = newGeoChatListener
    }
    
    /// Destroys geo chat listener.
    func removeGeoChatListener() {
        self.geoChatHasLoaded = false
        self.geoChatListener?.remove()
        self.geoChatListener = nil
        self.geoMessages = []
    }
    
    /// Calls a method to create a geo message in database.
    /// - Parameters:
    ///   - text: Message content.
    ///   - sender: Username of sender.
    ///   - userId: User ID of sender.
    ///   - boundingBox: Geospatial bounding box for this message.
    /// - Returns: Status of message operation.
    func createGeoMessage(text: String, sender: String, userId: String, boundingBox: BoundingBox?, adult: Bool) async -> MessageStatus {
        return await chatRepositoy.createGeoMessage(with: text, by: sender, with: userId, boundingBox: boundingBox, adult: adult)
    }
    
    /// Attaches a listener to tide chat messages.
    /// - Parameter tideId: ID of Tide with `messages` subcollection to fetch and listen to.
    func attachTideChatListener(tideId: String, blockedByUsers: [String], blockedUsers: [String: String]) {
        let newTideChatListener = chatRepositoy.attachTideChatListener(for: tideId, blockedByUsers: blockedByUsers, blockedUsers: blockedUsers) { [weak self] messages in
            if let messages {
                self?.tideMessages = messages
            } else {
                print("Something went wrong while fetching Tide messages")
                self?.tideMessages = []
            }
            self?.tideChatHasLoaded = true
        }
        self.tideChatListener?.remove()
        self.tideChatListener = newTideChatListener
    }
    
    /// Destroys Tide chat listener.
    func removeTideChatListener() {
        self.tideChatHasLoaded = false
        self.tideChatListener?.remove()
        self.tideChatListener = nil
        self.tideMessages = []
    }
    
    /// Create a Tide message document in the database.
    /// - Parameters:
    ///   - tideId: ID of Tide with `messages` subcollection.
    ///   - text: Message content.
    ///   - sender: Username of sender.
    ///   - userId: User ID of sender.
    /// - Returns: Status of message operation.
    func createTideMessage(tideId: String, text: String, sender: String, userId: String) async -> MessageStatus {
        return await chatRepositoy.createTideMessage(tideId: tideId, with: text, by: sender, with: userId)
    }
}
