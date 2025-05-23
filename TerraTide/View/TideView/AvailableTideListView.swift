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
    @State private var showCreateTide: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Available Tides")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                Button {
                    showCreateTide = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                }
                .padding(.trailing)
            }
            
            if tidesViewModel.availableTidesHaveLoaded {
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        // Group tides by their actual categories
                        ForEach(groupedTideCategories(), id: \.self) { category in
                            // Only show categories that have tides
                            if !tidesForCategory(category).isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    // Category header
                                    HStack {
                                        Text(category)
                                            .font(.headline)
                                            .foregroundColor(.white)
                                            .padding(.leading)
                                        
                                        Spacer()
                                        
                                        // No description displayed
                                    }
                                    
                                    // Horizontal scroll for this category
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 15) {
                                            // Show tides for this category
                                            ForEach(tidesForCategory(category), id: \.self) { tide in
                                                AvailableTideCard(
                                                    tideId: tide.id ?? "",
                                                    title: tide.title,
                                                    creator: tide.creatorUsername,
                                                    participants: "\(tide.participantCount)/\(tide.maxParticipants)",
                                                    description: tide.description,
                                                    category: tide.tideCategory.rawValue
                                                )
                                                .frame(width: 300)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                    .padding(.bottom, 5)
                                }
                            }
                        }
                    }
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
        .fullScreenCover(isPresented: $showCreateTide) {
            // This would navigate to your Create Tide view
            CreateTideView()
        }
    }
    
    // Get all categories that have tides
    private func groupedTideCategories() -> [String] {
        // Get all unique categories from available tides
        let categories = Set(tidesViewModel.availableTides.map { $0.tideCategory.rawValue })
        
        // Sort categories alphabetically
        return Array(categories).sorted()
    }
    
    // Get tides for a specific category
    private func tidesForCategory(_ category: String) -> [Tide] {
        return tidesViewModel.availableTides.filter { $0.tideCategory.rawValue == category }
    }
}

// Card for available tides with different colors
struct AvailableTideCard: View {
    let tideId: String
    let title: String
    let creator: String
    let participants: String
    var description: String = "Join this tide to collaborate with others and achieve your goals together."
    var category: String = "Popular"
    
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var singleTideViewModel: SingleTideViewModel
    @State private var isJoining: Bool = false
    @State private var joinStatus: String? = nil
    @State private var showJoinStatus: Bool = false
    
    // Colors for different categories
    private var categoryColors: [String: [Color]] {
        [
            // Social and Community
            "Social": [Color(red: 0.8, green: 0.5, blue: 0.2), Color(red: 0.6, green: 0.4, blue: 0.1)],
            "Networking": [Color(red: 0.4, green: 0.6, blue: 0.8), Color(red: 0.3, green: 0.5, blue: 0.7)],
            
            // Outdoor and Adventure
            "Outdoor": [Color(red: 0.3, green: 0.7, blue: 0.3), Color(red: 0.2, green: 0.5, blue: 0.2)],
            "Hiking": [Color(red: 0.2, green: 0.6, blue: 0.3), Color(red: 0.1, green: 0.5, blue: 0.2)],
            "Biking": [Color(red: 0.3, green: 0.7, blue: 0.4), Color(red: 0.2, green: 0.6, blue: 0.3)],
            "Climbing": [Color(red: 0.4, green: 0.6, blue: 0.3), Color(red: 0.3, green: 0.5, blue: 0.2)],
            "Camping": [Color(red: 0.3, green: 0.5, blue: 0.2), Color(red: 0.2, green: 0.4, blue: 0.1)],
            "Beach": [Color(red: 0.0, green: 0.7, blue: 0.9), Color(red: 0.0, green: 0.6, blue: 0.8)],
            "Sports": [Color(red: 0.2, green: 0.6, blue: 0.8), Color(red: 0.1, green: 0.5, blue: 0.7)],
            "Running": [Color(red: 0.8, green: 0.4, blue: 0.3), Color(red: 0.7, green: 0.3, blue: 0.2)],
            "Swimming": [Color(red: 0.0, green: 0.6, blue: 0.8), Color(red: 0.0, green: 0.5, blue: 0.7)],
            
            // Food and Drinks
            "Food": [Color(red: 0.8, green: 0.4, blue: 0.4), Color(red: 0.7, green: 0.3, blue: 0.3)],
            "Coffee": [Color(red: 0.6, green: 0.4, blue: 0.2), Color(red: 0.5, green: 0.3, blue: 0.1)],
            "Brunch": [Color(red: 0.9, green: 0.6, blue: 0.3), Color(red: 0.8, green: 0.5, blue: 0.2)],
            "Dinner": [Color(red: 0.7, green: 0.3, blue: 0.5), Color(red: 0.6, green: 0.2, blue: 0.4)],
            "Cooking": [Color(red: 0.8, green: 0.5, blue: 0.3), Color(red: 0.7, green: 0.4, blue: 0.2)],
            "Baking": [Color(red: 0.9, green: 0.7, blue: 0.5), Color(red: 0.8, green: 0.6, blue: 0.4)],
            "Wine Tasting": [Color(red: 0.6, green: 0.2, blue: 0.3), Color(red: 0.5, green: 0.1, blue: 0.2)],
            "Beer Tasting": [Color(red: 0.7, green: 0.5, blue: 0.2), Color(red: 0.6, green: 0.4, blue: 0.1)],
            
            // Arts and Culture
            "Arts": [Color(red: 0.8, green: 0.3, blue: 0.7), Color(red: 0.7, green: 0.2, blue: 0.6)],
            "Music": [Color(red: 0.5, green: 0.3, blue: 0.7), Color(red: 0.4, green: 0.2, blue: 0.6)],
            "Concerts": [Color(red: 0.6, green: 0.3, blue: 0.8), Color(red: 0.5, green: 0.2, blue: 0.7)],
            "Theater": [Color(red: 0.7, green: 0.2, blue: 0.5), Color(red: 0.6, green: 0.1, blue: 0.4)],
            "Museums": [Color(red: 0.5, green: 0.5, blue: 0.7), Color(red: 0.4, green: 0.4, blue: 0.6)],
            "Photography": [Color(red: 0.3, green: 0.3, blue: 0.3), Color(red: 0.2, green: 0.2, blue: 0.2)],
            "Dance": [Color(red: 0.9, green: 0.4, blue: 0.6), Color(red: 0.8, green: 0.3, blue: 0.5)],
            "Writing": [Color(red: 0.3, green: 0.5, blue: 0.7), Color(red: 0.2, green: 0.4, blue: 0.6)],
            "Book Club": [Color(red: 0.6, green: 0.4, blue: 0.7), Color(red: 0.5, green: 0.3, blue: 0.6)],
            
            // Learning and Growth
            "Learning": [Color(red: 0.5, green: 0.3, blue: 0.7), Color(red: 0.4, green: 0.2, blue: 0.6)],
            "Language Exchange": [Color(red: 0.3, green: 0.6, blue: 0.7), Color(red: 0.2, green: 0.5, blue: 0.6)],
            "Coding": [Color(red: 0.2, green: 0.5, blue: 0.6), Color(red: 0.1, green: 0.4, blue: 0.5)],
            "Business": [Color(red: 0.3, green: 0.4, blue: 0.6), Color(red: 0.2, green: 0.3, blue: 0.5)],
            "Investing": [Color(red: 0.2, green: 0.6, blue: 0.5), Color(red: 0.1, green: 0.5, blue: 0.4)],
            "Career": [Color(red: 0.4, green: 0.5, blue: 0.6), Color(red: 0.3, green: 0.4, blue: 0.5)],
            "Workshop": [Color(red: 0.5, green: 0.4, blue: 0.6), Color(red: 0.4, green: 0.3, blue: 0.5)],
            
            // Default colors for other categories
            "Other": [Color(red: 0.5, green: 0.5, blue: 0.5), Color(red: 0.4, green: 0.4, blue: 0.4)]
        ]
    }
    
    var body: some View {
        ZStack {
            // Card background with gradient - different colors based on category
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: categoryColors[category] ?? [Color(red: 0.8, green: 0.3, blue: 0.3), Color(red: 0.6, green: 0.2, blue: 0.2)]),
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
                    .lineLimit(4) // Increased line limit
                    .padding(.top, 8)
                    .padding(.bottom, 4)
                
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
        .frame(height: 240) // Increased height to accommodate more content
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
