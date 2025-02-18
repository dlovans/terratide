//
//  ChatViewModel.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-16.
//

import Foundation
import FirebaseFirestore

class ChatViewModel: ObservableObject {
    @Published var chatHasLoaded: Bool = false
    @Published var geoMessages: [Message] = []
    
    private var chatRepositoy = ChatRepository()
    private var geoChatListener: ListenerRegistration? = nil
    
    /// Attaches a listener to chat messages.
    /// - Parameter userLocation: User location with longitude and latitude values.
    func attachChatListener(userLocation: Coordinate) { // TODO: Consider returning status if messages fail to load.
        let newGeoChatListener = chatRepositoy.attachChatListener(for: userLocation) { [weak self] messages in
            if let messages {
                self?.geoMessages = messages
            } else {
                print("Something went wrong while fetching geo messages")
                self?.geoMessages = []
            }
            self?.chatHasLoaded = true
        }
        self.geoChatListener?.remove()
        self.geoChatListener = newGeoChatListener
    }
    
    /// Destroys geo chat listener.
    func removeChatListener() {
        self.chatHasLoaded = false
        self.geoChatListener?.remove()
        self.geoChatListener = nil
        self.geoMessages = []
    }
    
    
    /// Calls a method to create a message in database.
    /// - Parameters:
    ///   - text: Message content.
    ///   - sender: Username of sender.
    ///   - userId: User ID of sender.
    ///   - boundingBox: Geospatial bounding box for this message.
    /// - Returns: Status of message operation.
    func createMessage(text: String, sender: String, userId: String, boundingBox: BoundingBox?) async -> MessageStatus {
        return await chatRepositoy.createMessage(with: text, by: sender, with: userId, boundingBox: boundingBox)
    }
}
