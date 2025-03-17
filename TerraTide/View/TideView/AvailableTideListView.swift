//
//  AvailableTideListView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-02.
//

import SwiftUI

struct AvailableTideListView: View {
    @EnvironmentObject private var tidesViewModel: TidesViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var locationService: LocationService
    @EnvironmentObject private var singleTideViewModel: SingleTideViewModel
    @State private var joiningTide: Bool = false
    @State private var showTideDetail: Bool = false
    @State private var selectedTideId: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("Available Tides")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            }
            
            if tidesViewModel.availableTidesHaveLoaded {
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(tidesViewModel.availableTides, id: \.self) { tide in
                            // Card for available tides
                            AvailableTideCard(
                                tideId: tide.id ?? "",
                                title: tide.title,
                                creator: tide.creatorUsername,
                                participants: "\(tide.participantCount)/\(tide.maxParticipants)",
                                description: tide.description
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                .scrollIndicators(.hidden)
                .padding(.top, 10)
            } else {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                Spacer()
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.top, 7)
        .padding(.bottom, 20)
        .background(Color.clear) // Ensure background is transparent
        .onAppear {
            joiningTide = false
            Task { @MainActor in
                if let userId = userViewModel.user?.id,
                   let userLocation = locationService.userLocation {
                    // Using the correct parameters for the method
                    let isAdult = userViewModel.user?.adult ?? false
                    let blockedUsers = userViewModel.user?.blockedUsers ?? [:]
                    let blockedByUsers = userViewModel.user?.blockedByUsers ?? []
                    
                    tidesViewModel.attachAvailableTidesListener(
                        for: userLocation,
                        adult: isAdult,
                        userId: userId,
                        blockedUsers: blockedUsers,
                        blockedByUsers: blockedByUsers
                    )
                }
            }
        }
        .onDisappear {
            Task (priority: .background) {
                tidesViewModel.removeAvailableTidesListener()
                print("Available tides listener destroyed.")
            }
        }
        .onChange(of: singleTideViewModel.lastJoinedTideId) { oldValue, newValue in
            if let tideId = newValue, !tideId.isEmpty {
                print("New tide joined with ID: \(tideId)")
                selectedTideId = tideId
                showTideDetail = true
                // Reset lastJoinedTideId after we've handled it
                Task { @MainActor in
                    singleTideViewModel.lastJoinedTideId = nil
                }
            }
        }
        .fullScreenCover(isPresented: $showTideDetail) {
            TideDetailView(tideId: selectedTideId)
        }
    }
}

// Card for available tides with different colors
struct AvailableTideCard: View {
    let tideId: String
    let title: String
    let creator: String
    let participants: String
    var description: String = "Join this tide to collaborate with others and achieve your goals together."
    
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var singleTideViewModel: SingleTideViewModel
    @State private var isJoining: Bool = false
    @State private var joinStatus: String? = nil
    @State private var showJoinStatus: Bool = false
    
    var body: some View {
        ZStack {
            // Card background with gradient - different colors from ActiveTideListView
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.2, green: 0.6, blue: 0.5),  // Teal
                            Color(red: 0.1, green: 0.4, blue: 0.4)   // Deep teal
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                )
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                // Header with title and participants
                HStack {
                    Text(title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // Participant badge
                    HStack(spacing: 4) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 12))
                        Text(participants)
                            .font(.system(size: 12, weight: .medium))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.2))
                    .clipShape(Capsule())
                    .foregroundColor(.white)
                }
                
                // Creator with icon
                HStack(spacing: 6) {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.system(size: 14))
                    
                    Text(creator)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Description - increased line limit and added more vertical space
                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(3) // Increased from 2 to 3 lines
                    .padding(.top, 8) // Increased top padding
                    .padding(.bottom, 4) // Added bottom padding
                
                Spacer()
                
                // Join button - now full width
                Button {
                    joinTide()
                } label: {
                    HStack {
                        if isJoining {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                                .padding(.trailing, 5)
                        } else {
                            Text(isJoining ? "Joining..." : "Join")
                                .font(.system(size: 15, weight: .semibold))
                            
                            if !isJoining {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 15))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .foregroundColor(.white)
                }
                .disabled(isJoining)
            }
            .padding(16)
            
            // Status overlay
            if showJoinStatus, let status = joinStatus {
                VStack {
                    Text(status)
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
        .frame(height: 220) // Increased height to accommodate more description text
        .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
    }
    
    private func joinTide() {
        guard let userId = userViewModel.user?.id, 
              let username = userViewModel.user?.username else { return }
        
        isJoining = true
        
        Task {
            let status = await singleTideViewModel.joinTide(
                tideId: tideId,
                userId: userId,
                username: username
            )
            
            // Handle join status
            await MainActor.run {
                switch status {
                case .joined, .alreadyJoined:
                    joinStatus = status == .joined ? "Successfully joined tide!" : "You're already a member of this tide"
                    // Set the lastJoinedTideId to trigger navigation
                    DispatchQueue.main.async {
                        singleTideViewModel.lastJoinedTideId = tideId
                    }
                    
                case .invalidTide:
                    joinStatus = "Invalid tide data"
                case .noDocument:
                    joinStatus = "Tide not found"
                case .full:
                    joinStatus = "This tide is full"
                case .failed:
                    joinStatus = "Failed to join tide"
                }
                
                showJoinStatus = true
                
                // Hide status after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showJoinStatus = false
                    }
                }
                
                isJoining = false
            }
        }
    }
}

#Preview {
    AvailableTideListView()
}
