//
//  ActiveTideListView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-02.
//

import SwiftUI

struct ActiveTideListView: View {
    @EnvironmentObject private var tidesViewModel: TidesViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var singleTideViewModel: SingleTideViewModel
    @State private var openingOrLeavingTide: Bool = false
    @State private var showTideDetail: Bool = false
    @State private var selectedTideId: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("My Tides")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            }
            .padding(.top, 10)
            
            if tidesViewModel.activeTidesHaveLoaded {
                ScrollView {
                    // Add top padding to ensure first card doesn't overflow into safe area
                    LazyVStack(spacing: 15) {
                        // Add spacer at the top to push content down
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 10)
                        ForEach(tidesViewModel.activeTides, id: \.self) { tide in
                            // Simplified placeholder for ActiveTideItemView
                            SimpleTideCard(
                                title: tide.title,
                                creator: tide.creatorUsername,
                                participants: "\(tide.participantCount)/\(tide.maxParticipants)",
                                description: tide.description,
                                tideId: tide.id ?? "",
                                isCreator: tide.creatorId == userViewModel.user?.id,
                                category: tide.tideCategory.rawValue,
                                parentShowTideDetail: $showTideDetail,
                                parentSelectedTideId: $selectedTideId
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
                .scrollIndicators(.hidden)
                .padding(.top, 5)
            } else {
                Spacer()
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                Spacer()
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.top, 15)
        .padding(.bottom, 20)
        .background(Color.clear) // Ensure background is transparent
        .onAppear {
            openingOrLeavingTide = false
            Task { @MainActor in
                if let userId = userViewModel.user?.id {
                    tidesViewModel.attachActiveTidesListener(userId: userId)
                }
            }
        }
        .onDisappear {
            Task (priority: .background) {
                tidesViewModel.removeActiveTidesListener()
                print("Active tides listener destroyed.")
            }
        }
        .onChange(of: singleTideViewModel.lastJoinedTideId) { oldValue, newValue in
            if let tideId = newValue, !tideId.isEmpty {
                print("Tide with ID: \(tideId) was accessed")
                selectedTideId = tideId
                showTideDetail = true
                // Reset lastJoinedTideId after we've handled it
                Task { @MainActor in
                    singleTideViewModel.lastJoinedTideId = nil
                }
            }
        }
        .fullScreenCover(isPresented: $showTideDetail) {
            // When showing the detail view, ensure we have the correct tide ID
            // and that the tide listener is properly attached
            TideDetailView(tideId: selectedTideId)
                .onAppear {
                    // Ensure the tide listener is attached when the view appears
                    print("Ensuring tide listener is attached for ID: \(selectedTideId)")
                    singleTideViewModel.attachTideListener(tideId: selectedTideId)
                }
        }
    }
}

// Bare minimum card to avoid compiler issues
struct SimpleTideCard: View {
    let title: String
    let creator: String
    let participants: String
    var description: String = "Join this tide to collaborate with others and achieve your goals together."
    var tideId: String = ""
    var isCreator: Bool = false
    var category: String = "Other"
    
    @EnvironmentObject private var singleTideViewModel: SingleTideViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var isLeaving: Bool = false
    @State private var showLeaveStatus: Bool = false
    @State private var leaveStatus: String? = nil
    // Using parent view's state for navigation
    @Binding var parentShowTideDetail: Bool
    @Binding var parentSelectedTideId: String
    
    // Initialize with default parameters
    init(title: String, creator: String, participants: String, description: String = "Join this tide to collaborate with others and achieve your goals together.", tideId: String = "", isCreator: Bool = false, category: String = "Other", parentShowTideDetail: Binding<Bool>, parentSelectedTideId: Binding<String>) {
        self.title = title
        self.creator = creator
        self.participants = participants
        self.description = description
        self.tideId = tideId
        self.isCreator = isCreator
        self.category = category
        self._parentShowTideDetail = parentShowTideDetail
        self._parentSelectedTideId = parentSelectedTideId
    }
    
    var body: some View {
        ZStack {
            // Card background with gradient
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.85, green: 0.45, blue: 0.36), // Warm coral
                            Color(red: 0.7, green: 0.25, blue: 0.35)   // Deep rose
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
                
                // Category with tag icon
                HStack(spacing: 6) {
                    Image(systemName: "tag.fill")
                        .foregroundColor(.white.opacity(0.8))
                        .font(.system(size: 14))
                    
                    Text(category)
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
                
                HStack(spacing: 10) {
                    // Open button
                    Button(action: {
                        print("Opening tide: \(tideId)")
                        // Use the parent's binding to show the detail view
                        parentSelectedTideId = tideId
                        
                        // Ensure the tide listener is attached before showing the detail view
                        singleTideViewModel.attachTideListener(tideId: tideId)
                        
                        // Then show the detail view
                        parentShowTideDetail = true
                    }) {
                        HStack {
                            Text("Open")
                                .font(.system(size: 15, weight: .semibold))
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 15))
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
                    
                    // Leave button (only for non-creators)
                    if !isCreator {
                        Button(action: {
                            leaveTide()
                        }) {
                            HStack {
                                if isLeaving {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                        .padding(.trailing, 5)
                                } else {
                                    Text("Leave")
                                        .font(.system(size: 15, weight: .semibold))
                                    
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.system(size: 15))
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.2),
                                        Color.white.opacity(0.1)
                                    ]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .foregroundColor(.white)
                        }
                        .disabled(isLeaving)
                    }
                }
            }
            .padding(16)
            
            // Status overlay for leave feedback
            if showLeaveStatus, let status = leaveStatus {
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
    
    private func leaveTide() {
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
                    leaveStatus = "Successfully left tide"
                case .invalidData:
                    leaveStatus = "Invalid data provided"
                case .failed:
                    leaveStatus = "Failed to leave tide"
                case .noDocument:
                    leaveStatus = "Tide not found"
                case .notMember:
                    leaveStatus = "You are not a member of this tide"
                }
                
                showLeaveStatus = true
                
                // Hide status after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation {
                        showLeaveStatus = false
                    }
                }
                
                isLeaving = false
            }
        }
    }
}

#Preview {
    ActiveTideListView()
}
