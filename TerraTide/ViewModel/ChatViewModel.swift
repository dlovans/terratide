//
//  ChatViewModel.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-16.
//

import Foundation
import FirebaseFirestore

class ChatViewModel: ObservableObject {
    @Published var geoMessages: [Message] = []
    
    private var chatRepositoy = ChatRepository()
    private var geoChatListener: ListenerRegistration? = nil
    
    /// Attaches a listener to chat messages.
    /// - Parameter userLocation: User location with longitude and latitude values.
    func attachChatListener(userLocation: Coordinate) {
        self.geoChatListener?.remove()
        self.geoChatListener = nil
        self.geoChatListener = chatRepositoy.attachChatListener(for: userLocation) { [weak self] messages in
            if let messages {
                self?.geoMessages = messages
            } else {
                print("Something went wrong while fetching geo messages")
                self?.geoMessages = []
            }
        }
    }
}
