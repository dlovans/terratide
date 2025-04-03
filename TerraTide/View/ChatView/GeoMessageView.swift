//
//  GeoMessageView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-04-02.
//

import SwiftUI
import Foundation
import FirebaseFirestore

// Message bubble component
struct GeoMessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                // Username display
                Text(message.sender)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.95))
                    .padding(.horizontal, 4)
                    .padding(.bottom, 2)
                
                Text(message.text)
                    .padding(12)
                    .background(isCurrentUser ? 
                                Color(red: 0.2, green: 0.2, blue: 0.25).opacity(0.9) : // Slate for user
                                Color(red: 0.9, green: 0.85, blue: 0.7).opacity(0.85)) // Warm cream for others
                    .foregroundColor(isCurrentUser ? 
                                    Color.white : // White text on dark background for user
                                    Color(red: 0.25, green: 0.25, blue: 0.25)) // Dark text on cream for others
                    .cornerRadius(16)
                
                Text(formatTimestamp(message.timestamp))
                    .font(.system(size: 10))
                    .foregroundColor(Color.white.opacity(0.8))
                    .padding(.horizontal, 4)
            }
            
            if !isCurrentUser {
                Spacer()
            }
        }
    }
    
    // Format timestamp to readable time
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// GeoMessageView - A wrapper view for displaying a list of messages
struct GeoMessageView: View {
    let messages: [Message]
    let currentUserId: String
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(messages.isEmpty ? [] : messages) { message in
                GeoMessageBubble(
                    message: message,
                    isCurrentUser: message.byUserId == currentUserId
                )
                .id(message.id)
            }
        }
        .padding(.horizontal)
    }
}

// Preview provider for GeoMessageView
struct GeoMessageView_Previews: PreviewProvider {
    static var previews: some View {
        // Create sample messages for preview
        let sampleMessages: [Message] = [
            Message(
                id: "1",
                text: "Hello! Welcome to TerraTide Chat.",
                byUserId: "system",
                sender: "TerraTide",
                timestamp: Date(timeIntervalSinceNow: -3600),
                adult: false
            ),
            Message(
                id: "2",
                text: "Hi there! I'm new to TerraTide.",
                byUserId: "currentUser123",
                sender: "You",
                timestamp: Date(timeIntervalSinceNow: -1800),
                adult: false
            ),
            Message(
                id: "3",
                text: "Welcome! There are several meetups happening this weekend.",
                byUserId: "user456",
                sender: "Sarah",
                timestamp: Date(timeIntervalSinceNow: -1200),
                adult: false
            )
        ]
        
        return GeoMessageView(
            messages: sampleMessages,
            currentUserId: "currentUser123"
        )
        .background(Color.gray.opacity(0.2))
        .previewLayout(.sizeThatFits)
    }
}
