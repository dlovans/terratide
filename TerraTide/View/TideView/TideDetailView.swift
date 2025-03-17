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
    @State private var isLoading: Bool = true
    @State private var isJoining: Bool = false
    @State private var isLeaving: Bool = false
    @State private var showStatusMessage: Bool = false
    @State private var statusMessage: String = ""
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.4, blue: 0.4), // Warm red
                    Color(red: 0.95, green: 0.6, blue: 0.3)  // Warm orange
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Pattern overlay
            ZStack {
                ForEach(0..<20) { i in
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: CGFloat.random(in: 50...150))
                        .position(
                            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                            y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                        )
                }
            }
            .ignoresSafeArea()
            
            // Content
            VStack {
                // Navigation bar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Tide Details")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Placeholder to balance the back button
                    HStack {
                        Text("Back")
                            .font(.system(size: 16, weight: .semibold))
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .semibold))
                    }
                    .opacity(0)
                }
                .padding()
                .background(Color.black.opacity(0.2))
                
                if isLoading {
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
                                
                                // Chat button (if member)
                                if tide.members.keys.contains(userViewModel.user?.id ?? "") {
                                    Button {
                                        // Open chat action
                                    } label: {
                                        HStack {
                                            Text("Open Chat")
                                                .font(.system(size: 16, weight: .semibold))
                                            
                                            Image(systemName: "message.fill")
                                                .font(.system(size: 16))
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [
                                                    Color.blue.opacity(0.7),
                                                    Color.blue.opacity(0.5)
                                                ]),
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                    }
                                }
                                
                                // Close button
                                Button {
                                    dismiss()
                                } label: {
                                    HStack {
                                        Text("Close")
                                            .font(.system(size: 16, weight: .semibold))
                                        
                                        Image(systemName: "xmark.circle")
                                            .font(.system(size: 16))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color.gray.opacity(0.7),
                                                Color.gray.opacity(0.5)
                                            ]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
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
            // Load tide details
            singleTideViewModel.attachTideListener(tideId: tideId)
            
            // Add a delay to show loading indicator
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isLoading = false
            }
        }
        .onDisappear {
            // Clean up listener
            singleTideViewModel.removeTideListener()
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
                    statusMessage = "Successfully joined tide!"
                case .alreadyJoined:
                    statusMessage = "You're already a member of this tide"
                case .invalidTide:
                    statusMessage = "Invalid tide data"
                case .noDocument:
                    statusMessage = "Tide not found"
                case .full:
                    statusMessage = "This tide is full"
                case .failed:
                    statusMessage = "Failed to join tide"
                }
                
                showStatusMessage = true
                
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
                    statusMessage = "Successfully left tide"
                case .invalidData:
                    statusMessage = "Invalid data provided"
                case .failed:
                    statusMessage = "Failed to leave tide"
                case .noDocument:
                    statusMessage = "Tide not found"
                case .notMember:
                    statusMessage = "You are not a member of this tide"
                }
                
                showStatusMessage = true
                
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