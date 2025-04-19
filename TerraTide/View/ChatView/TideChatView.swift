//
//  TideChatView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-04-18.
//

import SwiftUI
import UIKit
import Foundation

// Using BackgroundBubble from ChatView.swift

struct TideChatView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var chatViewModel: ChatViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var singleTideViewModel: SingleTideViewModel
    @State private var messageText: String = ""
    @FocusState private var isInputFieldFocused: Bool
    
    // Add state to track keyboard notifications
    @State private var keyboardShown: Bool = false
    @State private var scrollToBottomOnKeyboardAppear: Bool = false
    
    // Animation state for bubble movement
    @State private var bubblesAppeared: Bool = false
    @State private var bubblePositions: [(x: CGFloat, y: CGFloat, size: CGFloat)] = []
    @State private var bubbleAnimationCounter: Int = 0
    @State private var shouldAnimateBubbles: Bool = false
    
    // Generate fixed bubble positions just once using custom tuples instead of BackgroundBubble
    private let backgroundBubbles: [(id: Int, size: CGFloat, xPosition: CGFloat, yPosition: CGFloat, initialOffset: CGFloat)] = {
        var bubbles = [(id: Int, size: CGFloat, xPosition: CGFloat, yPosition: CGFloat, initialOffset: CGFloat)]()
        for i in 0..<20 {
            bubbles.append((
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
                // Background gradient with purple theme
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.5, green: 0.3, blue: 0.8), // Purple
                        Color(red: 0.3, green: 0.2, blue: 0.6)  // Dark purple
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Animated bubble overlay
                ZStack {
                    if bubblePositions.isEmpty {
                        // Initial appearance animation using backgroundBubbles
                        ForEach(0..<backgroundBubbles.count, id: \.self) { i in
                            let bubble = backgroundBubbles[i]
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
                .onChange(of: shouldAnimateBubbles) { _, _ in 
                    if shouldAnimateBubbles {
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
                        // First, let's make sure the view is rendered
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                            // Generate positions first
                            generateBubblePositions(in: geometry)
                            
                            // Then trigger the appearance animation with a slight delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                bubblesAppeared = true
                                
                                // After appearance animation completes, trigger a subtle bubble movement
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    animateBubbles()
                                }
                            }
                        }
                    }
                }
                
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
                            
                            Text(singleTideViewModel.tide?.title ?? "Tide Chat")
                                .font(.headline)
                                .foregroundColor(.white)
                                .lineLimit(1)
                            
                            Spacer()
                            
                            // Empty view for balance with the same size as back button
                            Color.clear.frame(width: 60, height: 30)
                        }
                        .padding(.top, geometry.safeAreaInsets.top > 0 ? 0 : 10)
                        .background(Color.black.opacity(0.1))
                    
                    // Messages list
                    ScrollViewReader { scrollView in
                        ScrollView {
                            VStack(spacing: 12) {
                                // Spacer that pushes content to top when there are few messages
                                Spacer().frame(height: 0)
                                
                                // Messages
                                GeoMessageView(
                                    messages: chatViewModel.tideMessages,
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
                            if let lastMessageId = chatViewModel.tideMessages.last?.id {
                                scrollView.scrollTo(lastMessageId, anchor: .bottom)
                            }
                        }
                        .onChange(of: chatViewModel.tideMessages.count) { _, _ in
                            // Scroll to bottom when new messages are added
                            if let lastMessageId = chatViewModel.tideMessages.last?.id {
                                withAnimation {
                                    scrollView.scrollTo(lastMessageId, anchor: .bottom)
                                }
                            }
                        }
                        // Add onChange handler for keyboard appearance
                        .onChange(of: scrollToBottomOnKeyboardAppear) { _, _ in
                            if scrollToBottomOnKeyboardAppear {
                                if let lastMessageId = chatViewModel.tideMessages.last?.id {
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
                    
                    // Message input area with purple theme
                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            // Message input field with improved styling
                            ZStack(alignment: .leading) {
                                // Custom placeholder with better visibility
                                if messageText.isEmpty {
                                    Text("Type a message...")
                                        .foregroundColor(.white.opacity(0.7))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                }
                                
                                // Actual text field
                                TextField("", text: $messageText, axis: .vertical)
                                    .focused($isInputFieldFocused)
                                    .padding(12)
                                    .foregroundColor(.white) // Text color
                                    .tint(.white) // Cursor color
                                    .lineLimit(1...5) // Start with 1 line, allow up to 5
                                    .submitLabel(.send)
                                    .onSubmit {
                                        if !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                            animateBubbles()
                                            sendMessage()
                                        }
                                    }
                                    .onChange(of: messageText) { _, _ in
                                        // Limit to 250 characters while typing
                                        if messageText.count > 250 {
                                            messageText = String(messageText.prefix(250))
                                        }
                                    }
                                    .onTapGesture {
                                        // Make keyboard focus work better
                                        if !isInputFieldFocused {
                                            isInputFieldFocused = true
                                        }
                                    }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.1)) // Semi-transparent background
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(red: 0.5, green: 0.3, blue: 0.8).opacity(0.9), lineWidth: 1.5) // Purple border
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 12)) // Clip to match border
                            
                            // Send button with purple theme
                            Button {
                                animateBubbles()
                                sendMessage()
                            } label: {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 36))
                                    .foregroundColor(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 
                                                    Color.gray.opacity(0.5) : 
                                                    Color(red: 0.7, green: 0.5, blue: 0.9)) // Light purple
                                    .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                                    .frame(width: 44, height: 44)
                            }
                            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
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
            .onAppear {
                // Setup keyboard notifications
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
                    keyboardShown = true
                    scrollToBottomOnKeyboardAppear = true
                }
                
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    keyboardShown = false
                }
            }
        }
    }
    
    // Send message function
    func sendMessage() {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !trimmedText.isEmpty, let userId = userViewModel.user?.id, let username = userViewModel.user?.username {
            // Create message
            Task {
                let _ = await chatViewModel.createTideMessage(
                    with: trimmedText,
                    by: username,
                    with: userId
                )
            }
            
            // Clear input field
            messageText = ""
        }
    }
    
    // Helper function to hide keyboard
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    // Function to generate random bubble positions
    private func generateBubblePositions(in geometry: GeometryProxy) {
        bubblePositions = (0..<backgroundBubbles.count).map { i in 
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
}



struct TideChatView_Previews: PreviewProvider {
    static var previews: some View {
        TideChatView()
            .environmentObject(ChatViewModel())
            .environmentObject(UserViewModel())
            .environmentObject(SingleTideViewModel())
    }
}