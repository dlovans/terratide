//
//  ChatView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-04-02.
//

import SwiftUI
import UIKit
import Foundation

struct ChatView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @EnvironmentObject private var locationService: LocationService
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var messageText: String = ""
    @State private var bubblesAppeared: Bool = false
    
    // Animation state for bubble movement
    @State private var bubblePositions: [(x: CGFloat, y: CGFloat, size: CGFloat)] = []
    @State private var bubbleAnimationCounter: Int = 0
    @State private var shouldAnimateBubbles: Bool = false
    
    // Add state to track keyboard notifications
    @State private var keyboardShown: Bool = false
    @State private var scrollToBottomOnKeyboardAppear: Bool = false
    @FocusState private var isInputFieldFocused: Bool
    
    // Generate fixed bubble positions just once
    private let backgroundBubbles: [BackgroundBubble] = {
        var bubbles = [BackgroundBubble]()
        for i in 0..<20 {
            bubbles.append(BackgroundBubble(
                id: i,
                size: CGFloat.random(in: 50...150),
                xPosition: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                yPosition: CGFloat.random(in: 0...UIScreen.main.bounds.height),
                initialOffset: CGFloat.random(in: 20...50) * (Bool.random() ? 1 : -1)
            ))
        }
        return bubbles
    }()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient matching app style
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.95, green: 0.4, blue: 0.4), // Warm red
                        Color(red: 0.95, green: 0.6, blue: 0.3)  // Warm orange
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Animated bubble overlay
                ZStack {
                    if bubblePositions.isEmpty {
                        // Initial appearance animation using backgroundBubbles
                        ForEach(backgroundBubbles) { bubble in
                            Circle()
                                .fill(Color.white.opacity(0.1))
                                .frame(width: bubble.size)
                                .position(x: bubble.xPosition, y: bubble.yPosition)
                                // Initial offset that moves to 0 when appeared
                                .offset(
                                    x: bubblesAppeared ? 0 : bubble.initialOffset,
                                    y: bubblesAppeared ? 0 : bubble.initialOffset
                                )
                                // Only animate during appearance
                                .animation(
                                    .spring(dampingFraction: 0.7)
                                    .delay(Double(bubble.id) * 0.03), // Staggered delay
                                    value: bubblesAppeared
                                )
                        }
                    } else {
                        // Dynamically animated bubbles for interactions
                        ForEach(0..<20, id: \.self) { i in
                            if i < bubblePositions.count {
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: bubblePositions[i].size)
                                    .position(x: bubblePositions[i].x, y: bubblePositions[i].y)
                                    .animation(.easeInOut(duration: 0.7), value: bubbleAnimationCounter)
                            }
                        }
                    }
                }
                .onChange(of: shouldAnimateBubbles) { oldValue, newValue in
                    if newValue {
                        triggerBubbleAnimation()
                        // Auto-reset after animation is triggered
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            shouldAnimateBubbles = false
                        }
                    }
                }
                .ignoresSafeArea()
                .allowsHitTesting(false) // Prevent interaction with bubbles
                .onAppear {
                    // Trigger the appearance animation only if bubblePositions is empty
                    if bubblePositions.isEmpty {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            bubblesAppeared = true
                        }
                        
                        // After initial animation, set up dynamic bubble positions
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            generateBubblePositions(in: geometry)
                        }
                    }
                }
                
                // Loading overlay
                if !chatViewModel.geoChatHasLoaded {
                    VStack {
                        Text("Loading chat...")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                            .padding()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.3))
                    .ignoresSafeArea()
                } else {
                    // Chat content
                    VStack(spacing: 0) {
                        // Header with back button - reduced size
                        HStack {
                            Button {
                                animateBubbles()
                                dismiss()
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 16))
                                    Text("Back")
                                        .font(.system(size: 14))
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                            }
                            
                            Spacer()
                            
                            Text("TerraTide Chat")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            // Empty view for balance with the same size as back button
                            Color.clear.frame(width: 60, height: 30)
                        }
                        .padding(.top, geometry.safeAreaInsets.top > 0 ? 0 : 10)
                        .background(Color.black.opacity(0.1))
                        
                        // Messages list - fixed to align messages to the top
                        ScrollViewReader { scrollView in
                            ScrollView {
                                VStack(spacing: 12) {
                                    // Spacer that pushes content to top when there are few messages
                                    Spacer().frame(height: 0)
                                    
                                    // Messages - now using the GeoMessageView component
                                    GeoMessageView(
                                        messages: chatViewModel.geoMessages,
                                        currentUserId: userViewModel.user?.id ?? ""
                                    )
                                    .padding(.horizontal)
                                }
                                .padding(.vertical)
                                .frame(minHeight: geometry.size.height - 100, alignment: .top)
                            }
                            .simultaneousGesture(
                                DragGesture(minimumDistance: 10)
                                    .onChanged { _ in
                                        // Dismiss keyboard when scrolling
                                        hideKeyboard()
                                    }
                            )
                            .onAppear {
                                // Scroll to bottom initially
                                if let lastMessageId = chatViewModel.geoMessages.last?.id {
                                    scrollView.scrollTo(lastMessageId, anchor: .bottom)
                                }
                            }
                            .onChange(of: chatViewModel.geoMessages.count) {
                                // Scroll to bottom when new messages are added
                                if let lastMessageId = chatViewModel.geoMessages.last?.id {
                                    withAnimation {
                                        scrollView.scrollTo(lastMessageId, anchor: .bottom)
                                    }
                                }
                            }
                            // Add onChange handler for keyboard appearance
                            .onChange(of: scrollToBottomOnKeyboardAppear) {
                                if scrollToBottomOnKeyboardAppear {
                                    if let lastMessageId = chatViewModel.geoMessages.last?.id {
                                        // Use a slight delay to ensure this happens after layout updates
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                            withAnimation(.easeOut(duration: 0.25)) {
                                                scrollView.scrollTo(lastMessageId, anchor: .bottom)
                                            }
                                        }
                                    }
                                    // Reset the flag after initiating the scroll
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        scrollToBottomOnKeyboardAppear = false
                                    }
                                }
                            }
                        }
                        .background(Color.black.opacity(0.05))
                        
                        // Simple input area with TextField
                        VStack(spacing: 0) {
                            HStack(spacing: 12) {
                                // Message input field with improved styling
                                TextField("Type a message...", text: $messageText, axis: .vertical)
                                    .focused($isInputFieldFocused)
                                    .padding(12)
                                    .background(Color.black.opacity(0.1)) // Semi-transparent background
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(red: 0.0, green: 0.6, blue: 0.5).opacity(0.9), lineWidth: 1.5) // Light emerald green border
                                    )
                                    .foregroundColor(.white) // Text color
                                    .tint(.white) // Cursor color
                                    .lineLimit(1...5) // Start with 1 line, allow up to 5
                                    .submitLabel(.send)
                                    .onSubmit {
                                        if !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                            animateBubbles() // Animate bubbles when sending with return key
                                            sendMessage()
                                        }
                                    }
                                    .onChange(of: messageText) { 
                                        // Limit to 250 characters while typing (behind the scenes)
                                        if messageText.count > 250 {
                                            messageText = String(messageText.prefix(250))
                                        }
                                    }
                                    .onTapGesture {
                                        // Make keyboard focus work better
                                        if !isInputFieldFocused {
                                            isInputFieldFocused = true
                                            scrollToBottom()
                                        }
                                    }
                                
                                // Send button - enhanced style
                                Button {
                                    animateBubbles() // Animate bubbles when sending with button
                                    sendMessage()
                                } label: {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.system(size: 36))
                                        .foregroundColor(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 
                                                        Color.gray.opacity(0.5) : 
                                                        Color(red: 0.0, green: 0.6, blue: 0.5).opacity(0.9)) // Match emerald border color
                                        .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                                        .frame(width: 44, height: 44)
                                }
                                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            .background(
                                // Gradient background for input container
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.black.opacity(0.05),
                                        Color.black.opacity(0.1)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .contentShape(Rectangle())
                            .onTapGesture {
                                // Do nothing, just intercept taps
                            }
                            // Add a gesture to dismiss keyboard when dragging
                            .gesture(
                                DragGesture(minimumDistance: 5)
                                    .onChanged { _ in
                                        hideKeyboard()
                                    }
                            )
                        }
                    }
                }
            }
            .onAppear {
                setupGeoChatListener()
                
                // Add keyboard observers
                NotificationCenter.default.addObserver(
                    forName: UIResponder.keyboardWillShowNotification,
                    object: nil,
                    queue: .main
                ) { _ in
                    keyboardShown = true
                    // Scroll to bottom with a slight delay to ensure we catch even the first keyboard toggle
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            scrollToBottomOnKeyboardAppear = true
                        }
                    }
                }
                
                NotificationCenter.default.addObserver(
                    forName: UIResponder.keyboardWillHideNotification,
                    object: nil,
                    queue: .main
                ) { _ in
                    keyboardShown = false
                }
            }
            .onChange(of: locationService.userLocation) { 
                setupGeoChatListener()
            }
            // Add onChange handlers for blocked users
            .onChange(of: userViewModel.user?.blockedUsers) { 
                setupGeoChatListener()
            }
            .onChange(of: userViewModel.user?.blockedByUsers) { 
                setupGeoChatListener()
            }
            .onDisappear {
                chatViewModel.removeGeoChatListener()
                
                // Remove keyboard observers
                NotificationCenter.default.removeObserver(
                    self,
                    name: UIResponder.keyboardWillShowNotification,
                    object: nil
                )
                NotificationCenter.default.removeObserver(
                    self,
                    name: UIResponder.keyboardWillHideNotification,
                    object: nil
                )
            }
        }
    }
    
    // Function to generate random bubble positions
    private func generateBubblePositions(in geometry: GeometryProxy) {
        bubblePositions = (0..<20).map { i in 
            (
                x: backgroundBubbles[i].xPosition, // Use the same positions as initial bubbles
                y: backgroundBubbles[i].yPosition,
                size: backgroundBubbles[i].size
            )
        }
    }
    
    // More reliable animation trigger function
    private func animateBubbles() {
        shouldAnimateBubbles = true
    }
    
    // Function to trigger bubble animation
    private func triggerBubbleAnimation() {
        // Significantly modify bubble positions to create movement
        for i in 0..<bubblePositions.count {
            // Dramatic random movement
            let xOffset = CGFloat.random(in: -80...80)
            let yOffset = CGFloat.random(in: -80...80)
            bubblePositions[i].x += xOffset
            bubblePositions[i].y += yOffset
        }
        
        // Increment counter to trigger animation
        bubbleAnimationCounter += 1
    }
    
    // Helper function to set up geo chat listener
    private func setupGeoChatListener() {
        guard let userLocation = locationService.userLocation else { return }
        
        // Get blocked users information from userViewModel
        let blockedByUsers = userViewModel.user?.blockedByUsers ?? []
        let blockedUsers = userViewModel.user?.blockedUsers ?? [:]
        
        // Use the ChatViewModel to attach a listener for geo messages
        chatViewModel.attachGeoChatListener(
            userLocation: userLocation, 
            adult: userViewModel.user?.adult ?? false, 
            blockedByUsers: blockedByUsers, 
            blockedUsers: blockedUsers
        )
    }
    
    // Helper function to hide keyboard
    private func hideKeyboard() {
        isInputFieldFocused = false
    }
    
    // Helper function to explicitly scroll to the bottom of the chat
    private func scrollToBottom() {
        scrollToBottomOnKeyboardAppear = true
    }
    
    private func sendMessage() {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        // Limit message to 250 characters
        let limitedText = String(trimmedText.prefix(250))
        
        // Clear the input field immediately for better user experience
        messageText = ""
        
        // Ensure keyboard stays focused after sending
        isInputFieldFocused = true
        
        // Send the message asynchronously
        Task {
            guard let userLocation = locationService.userLocation else { return }
            print("User location: \(userLocation)")
            
            // Get user information from userViewModel
            let username = userViewModel.user?.username ?? ""
            let userId = userViewModel.user?.id ?? ""
            
            // Send message using the ViewModel
            let status = await chatViewModel.createGeoMessage(
                text: limitedText,
                sender: username,
                userId: userId,
                boundingBox: locationService.boundingBox,
                adult: userViewModel.user?.adult ?? false
            )
            
            // Handle any potential errors from message sending
            // MessageStatus enum cases: sent, failedToCreate, emptyMessage, invalidLocation, invalidData
            if status != .sent {
                // Show an error message to the user
                print("Failed to send message with status: \(status)")
            } else {
                // Ensure we scroll to the bottom after sending
                // We do this on main thread since we're updating the UI
                await MainActor.run {
                    // Use a small delay to ensure the message is added to the array first
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        scrollToBottom()
                    }
                }
            }
        }
    }
    
    // Helper function kept but not used
    private func getRandomResponse() -> String {
        let responses = [
            "Hey there! How's it going?",
            "Anyone want to meet up at the beach today?",
            "I'm looking for people to join my hiking group this weekend.",
            "Has anyone tried the new café downtown?",
            "I'm organizing a community cleanup event next week if anyone's interested!",
            "Does anyone know if the farmer's market is open tomorrow?",
            "I'm new to the area. Any recommendations for good restaurants?",
            "Weather's looking great today! Perfect for outdoor activities.",
            "Anyone interested in a board game meetup on Friday?",
            "Just wanted to say hi to everyone in the community!"
        ]
        
        return responses.randomElement() ?? "Hello there!"
    }
}

struct BackgroundBubble: Identifiable {
    let id: Int
    let size: CGFloat
    let xPosition: CGFloat
    let yPosition: CGFloat
    let initialOffset: CGFloat
}

#Preview {
    ChatView()
}
