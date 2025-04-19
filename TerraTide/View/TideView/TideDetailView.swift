//
//  TideDetailView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-03-17.
//

import SwiftUI

struct TideDetailView: View {
    let tideId: String
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var singleTideViewModel: SingleTideViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    // Using ViewModel's loading state instead of local state
    @State private var isJoining: Bool = false
    @State private var isLeaving: Bool = false
    @State private var showStatusMessage: Bool = false
    @State private var statusMessage: String = ""
    @State private var showTideChat: Bool = false
    @EnvironmentObject private var chatViewModel: ChatViewModel
    
    var body: some View {
        ZStack {
            // Background gradient with dark teal/slate tones (avoiding orange, purple, blue, green)
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.3, blue: 0.35), // Dark slate
                    Color(red: 0.3, green: 0.4, blue: 0.45)  // Muted teal
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Pattern overlay with animated bubbles
            ZStack {
                ForEach(0..<20) { i in
                    // Use GeometryReader to get the screen size
                    GeometryReader { geometry in
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: CGFloat.random(in: 50...150))
                            // Position bubbles based on screen size
                            .position(
                                x: CGFloat.random(in: 0...geometry.size.width),
                                y: CGFloat.random(in: 0...geometry.size.height)
                            )
                            // Add subtle animation when tide data loads
                            .offset(y: singleTideViewModel.tideHasLoaded ? 0 : CGFloat.random(in: 20...40))
                            .opacity(singleTideViewModel.tideHasLoaded ? 1.0 : 0.0)
                            .animation(
                                .spring(dampingFraction: 0.7)
                                .delay(Double(i) * 0.03), // Staggered delay
                                value: singleTideViewModel.tideHasLoaded
                            )
                    }
                }
            }
            .ignoresSafeArea()
            .allowsHitTesting(false) // Prevent interaction with bubbles
            
            // Content
            VStack {
                // Modern navigation bar with blur effect
                ZStack {
                    // Blur background
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .opacity(0.7)
                        .edgesIgnoringSafeArea(.top) // Extend to top of screen
                    
                    // Use ZStack to ensure title is always centered regardless of button sizes
                    ZStack {
                        // Center title
                        HStack {
                            Spacer()
                            Text("Tide Details")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                            Spacer()
                        }
                        
                        // Left and right buttons
                        HStack {
                            // Back button with modern icon
                            Button {
                                dismiss()
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 18, weight: .medium))
                                    Text("Back")
                                        .font(.system(size: 16, weight: .medium))
                                }
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(10)
                            }
                            
                            Spacer()
                            
                            // Chat button in navbar (only if user is a member)
                            if let tide = singleTideViewModel.tide, tide.members.keys.contains(userViewModel.user?.id ?? "") {
                                Button {
                                    // Setup tide chat listener before showing chat
                                    if let blockedUsers = userViewModel.user?.blockedUsers,
                                       let blockedByUsers = userViewModel.user?.blockedByUsers {
                                        chatViewModel.attachTideChatListener(tideId: tideId, 
                                                                            blockedByUsers: blockedByUsers, 
                                                                            blockedUsers: blockedUsers)
                                        showTideChat = true
                                    }
                                } label: {
                                    Image(systemName: "message.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                        .padding(8)
                                        .background(Color.white.opacity(0.15))
                                        .cornerRadius(10)
                                }
                            } else {
                                // Empty view to balance layout when chat button isn't shown
                                Color.clear
                                    .frame(width: 40, height: 40)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                .frame(height: 56)
                
                if !singleTideViewModel.tideHasLoaded {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    Spacer()
                } else if let tide = singleTideViewModel.tide {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Title
                            Text(tide.title)
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            // Creator info
                            HStack {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Text("Created by: \(tide.creatorUsername)")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .padding(.horizontal)
                            
                            // Participants
                            HStack {
                                Image(systemName: "person.3.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Text("Participants: \(tide.participantCount)/\(tide.maxParticipants)")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .padding(.horizontal)
                            
                            // Category
                            HStack {
                                Image(systemName: "tag.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Text("Category: \(tide.tideCategory.rawValue)")
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            .padding(.horizontal)
                            
                            // Description
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Description")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                Text(tide.description)
                                    .font(.system(size: 16))
                                    .foregroundColor(.white.opacity(0.9))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding(.horizontal)
                            .padding(.top, 10)
                            
                            // Action buttons
                            VStack(spacing: 12) {
                                // Leave button (if not creator and is member)
                                if tide.creatorId != userViewModel.user?.id && tide.members.keys.contains(userViewModel.user?.id ?? "") {
                                    Button {
                                        leaveTide(tideId: tideId)
                                    } label: {
                                        HStack {
                                            if isLeaving {
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                    .scaleEffect(0.8)
                                                    .padding(.trailing, 5)
                                            } else {
                                                Text("Leave Tide")
                                                    .font(.system(size: 16, weight: .semibold))
                                                
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.system(size: 16))
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.red.opacity(0.7),
                                                    Color.red.opacity(0.5)
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                    }
                                    .disabled(isLeaving)
                                }
                                
                                // Join button (if not member)
                                if !tide.members.keys.contains(userViewModel.user?.id ?? "") {
                                    Button {
                                        joinTide(tideId: tideId)
                                    } label: {
                                        HStack {
                                            if isJoining {
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                    .scaleEffect(0.8)
                                                    .padding(.trailing, 5)
                                            } else {
                                                Text("Join Tide")
                                                    .font(.system(size: 16, weight: .semibold))
                                                
                                                Image(systemName: "plus.circle.fill")
                                                    .font(.system(size: 16))
                                            }
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.green.opacity(0.7),
                                                    Color.green.opacity(0.5)
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                    }
                                    .disabled(isJoining)
                                }
                                
                                // Chat button removed - now in navbar
                                
                                // Close button removed
                            }
                            .padding(.horizontal)
                            .padding(.top, 20)
                            
                            // Members section moved below action buttons
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Members")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                
                                ForEach(Array(tide.members.keys), id: \.self) { userId in
                                    if let username = tide.members[userId] {
                                        HStack {
                                            Image(systemName: "person.fill")
                                                .font(.system(size: 14))
                                                .foregroundColor(.white.opacity(0.8))
                                            
                                            Text(username)
                                                .font(.system(size: 16))
                                                .foregroundColor(.white.opacity(0.9))
                                            
                                            Spacer()
                                            
                                            if userId == tide.creatorId {
                                                Text("Creator")
                                                    .font(.system(size: 12, weight: .semibold))
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color.orange.opacity(0.6))
                                                    .cornerRadius(8)
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 20)
                            .padding(.bottom, 30)
                        }
                        .padding(.vertical)
                    }
                } else {
                    Spacer()
                    Text("Tide not found")
                        .font(.title)
                        .foregroundColor(.white)
                    Spacer()
                }
            }
            
            // Status overlay
            if showStatusMessage {
                VStack {
                    Text(statusMessage)
                        .font(.headline)
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.3))
                .transition(.opacity)
            }
        }
        .onAppear {
            // Load tide details - tideHasLoaded will be set to true in the ViewModel
            singleTideViewModel.attachTideListener(tideId: tideId)
        }
        .onDisappear {
            // Clean up listeners
            print("Removing tide listener and chat listener")
            singleTideViewModel.removeTideListener()
            chatViewModel.removeTideChatListener()
        }
        .fullScreenCover(isPresented: $showTideChat) {
            TideChatView()
                .onDisappear {
                    // No need to remove the listener here as we want to keep it active
                    // while the TideDetailView is still visible
                }
        }
    }
    
    private func joinTide(tideId: String) {
        guard let userId = userViewModel.user?.id,
              let username = userViewModel.user?.username else { return }
        
        isJoining = true
        
        Task {
            let status = await singleTideViewModel.joinTide(
                tideId: tideId,
                userId: userId,
                username: username
            )
            
            await MainActor.run {
                switch status {
                case .joined:
                    // Success case - don't show message
                    showStatusMessage = false
                case .alreadyJoined:
                    statusMessage = "You're already a member of this tide"
                    showStatusMessage = true
                case .invalidTide:
                    statusMessage = "Invalid tide data"
                    showStatusMessage = true
                case .noDocument:
                    statusMessage = "Tide not found"
                    showStatusMessage = true
                case .full:
                    statusMessage = "This tide is full"
                    showStatusMessage = true
                case .failed:
                    statusMessage = "Failed to join tide"
                    showStatusMessage = true
                }
                
                // Hide status after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showStatusMessage = false
                    }
                }
                
                isJoining = false
            }
        }
    }
    
    private func leaveTide(tideId: String) {
        guard let userId = userViewModel.user?.id else { return }
        
        isLeaving = true
        
        Task {
            let status = await singleTideViewModel.leaveTide(
                tideId: tideId,
                userId: userId
            )
            
            await MainActor.run {
                switch status {
                case .left:
                    // Success case - don't show message
                    showStatusMessage = false
                case .invalidData:
                    statusMessage = "Invalid data provided"
                    showStatusMessage = true
                case .failed:
                    statusMessage = "Failed to leave tide"
                    showStatusMessage = true
                case .noDocument:
                    statusMessage = "Tide not found"
                    showStatusMessage = true
                case .notMember:
                    statusMessage = "You are not a member of this tide"
                    showStatusMessage = true
                }
                
                // Hide status after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showStatusMessage = false
                    }
                }
                
                isLeaving = false
            }
        }
    }
}

#Preview {
    TideDetailView(tideId: "previewTideId")
} 