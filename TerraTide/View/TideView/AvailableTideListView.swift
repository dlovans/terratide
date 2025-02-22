//
//  AvailableTideListView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-01-25.
//

import SwiftUI

struct AvailableTideListView: View {
    @EnvironmentObject private var tidesViewModel: TidesViewModel
    @EnvironmentObject private var locationService: LocationService
    @EnvironmentObject private var userViewModel: UserViewModel
    @Binding var path: [Route]
    
    @State private var attemptingToJoinTide: Bool = false
    
    var body: some View {
        ZStack {
            if tidesViewModel.availableTidesHaveLoaded {
                VStack {
                    HStack {
                        Button {
                            print("Don't touch.")
                        } label: {
                            Image(systemName: "plus.circle")
                                .foregroundStyle(.orange)
                                .font(.largeTitle)
                        }
                        .hidden()
                        Spacer()
                        Text("Available Tides")
                            .fixedSize(horizontal: true, vertical: false)
                        Spacer()
                        Button {
                            path.append(.general("createTide"))
                        } label: {
                            Image(systemName: "plus.circle")
                                .foregroundStyle(.orange)
                                .font(.system(size: 28))
                        }
                    }
                    .padding(.horizontal, 5)
                    
                    ScrollView {
                        LazyVStack {
                            ForEach(tidesViewModel.availableTides) { tide in
                                TideItemView(tide: tide, path: $path, attemptingToJoinTide: $attemptingToJoinTide)
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                }
            } else {
                LoadingView()
            }
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .bottom)
        .onAppear {
            Task { @MainActor in
                if let userLocation = locationService.userLocation, let user = userViewModel.user {
                    tidesViewModel.attachAvailableTidesListener(
                        for: userLocation,
                        userId: user.id,
                        blockedUsers: user.blockedUsers,
                        blockedByUsers: user.blockedByUsers
                    )
                }
            }
        }
        .onChange(of: userViewModel.user?.blockedUsers) { _, _ in
            Task {
                if let userLocation = locationService.userLocation, let user = userViewModel.user {
                    tidesViewModel.attachAvailableTidesListener(
                        for: userLocation,
                        userId: user.id,
                        blockedUsers: user.blockedUsers,
                        blockedByUsers: user.blockedByUsers
                    )
                }
            }
        }
        .onChange(of: userViewModel.user?.blockedUsers) { _, _ in
            Task {
                if let userLocation = locationService.userLocation, let user = userViewModel.user {
                    tidesViewModel.attachAvailableTidesListener(
                        for: userLocation,
                        userId: user.id,
                        blockedUsers: user.blockedUsers,
                        blockedByUsers: user.blockedByUsers
                    )
                }
            }
        }
        .onDisappear {
            Task { @MainActor in
                tidesViewModel.removeAvailableTidesListener()
            }
        }
    }
}

struct TideItemView: View {
    let tide: Tide
    @Binding var path: [Route]
    @Binding var attemptingToJoinTide: Bool
    
    @EnvironmentObject private var singleTideViewModel: SingleTideViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var actionButtonText: String = "Join"
    @State private var showReportTideSheet: Bool = false
    @State private var showBlockingAlert: Bool = false
    @State private var errorMessage: String = ""
    @State private var displayErrorMessage: Bool = false
    
    var body: some View {
        ZStack {
            VStack (spacing: 10) {
                Text(tide.title)
                    .frame(maxWidth: .infinity,alignment: .leading)
                Divider()
                    .background(.gray)
                Text(tide.description)
                    .frame(maxWidth: .infinity,alignment: .leading)
                Divider()
                    .background(.gray)
                HStack {
                    Text("By: \(tide.creatorUsername)")
                    Spacer()
                    Image(systemName: "person.fill")
                    Text("\(tide.participantCount)/\(tide.maxParticipants)")
                }
                
                HStack {
                    Button {
                        Task {@MainActor in
                            attemptingToJoinTide = true
                            if let user = userViewModel.user, let tideId = tide.id {
                                let status = await singleTideViewModel.joinTide(tideId: tideId, userId: user.id, username: user.username)
                                
                                var hasJoined = false
                                
                                switch status {
                                case .invalidTide:
                                    actionButtonText = "Could not find Tide :("
                                case .noDocument:
                                    actionButtonText = "Could not find Tide :("
                                case .alreadyJoined:
                                    actionButtonText = "Already a member...weird"
                                case .full:
                                    actionButtonText = "Tide is full :("
                                case .failed:
                                    actionButtonText = "Could not join Tide :(, something went wrong."
                                case .joined:
                                    hasJoined = true
                                    path.append(.tide(tide.id!))
                                }
                                
                                if !hasJoined {
                                    attemptingToJoinTide = false
                                }
                            } else {
                                attemptingToJoinTide = false
                            }
                        }
                    } label: {
                        HStack {
                            Text(actionButtonText)
                            Image(systemName: "arrow.forward")
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(10)
                        .background(attemptingToJoinTide ? .gray : .orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        
                    }
                    .buttonStyle(RemoveHighlightButtonStyle())
                    .disabled(attemptingToJoinTide)
                }
                
            }
            .padding()
            .overlay {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 1)
                    .blur(radius: 20)
            }
            .overlay {
                VStack {
                    Text(errorMessage)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black)
                .scaleEffect(displayErrorMessage ? 1 : 0)
                .animation(.spring, value: displayErrorMessage)
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .background(.white)
        .onAppear {
            attemptingToJoinTide = false
        }
        .contextMenu {
            if userViewModel.user?.id != tide.creatorId {
                Button {
                    showReportTideSheet = true
                } label: {
                    Text("Report")
                }
                Button {
                    showBlockingAlert = true
                } label: {
                    Text("Block User")
                }
            }
        }
        .sheet(isPresented: $showReportTideSheet) {
            ReportView(reportType: .tide, tideId: tide.id ?? "", reportByUserId: userViewModel.user?.id ?? "", reportAgainstUserId: tide.creatorId, showReportSheet: $showReportTideSheet)
        }
        .alert("Blocking this user will hide their Tides and messages.", isPresented: $showBlockingAlert) {
            Button(role: .cancel) {
                showBlockingAlert = false
            } label: {
                Text("Cancel")
                    .foregroundStyle(.black)
                    .background(.blue)
            }
            Button(role: .destructive) {
                Task { @MainActor in
                    let blockStatus = await userViewModel.blockUser(blocking: tide.creatorId, againstUsername: tide.creatorUsername, by: userViewModel.user?.id ?? "")
                    
                    var isError: Bool = false
                    
                    switch blockStatus {
                    case .blocked:
                        showBlockingAlert = false
                    case .failed:
                        isError = true
                        errorMessage = "Failed to block user."
                    case .alreadyBlocked:
                        isError = true
                        errorMessage = "This user is already blocked."
                    case .missingData:
                        isError = true
                        errorMessage = "Something went wrong. Please try again later."
                    case .userBlockingNotFound:
                        isError = true
                        errorMessage = "Could not find the user you are trying to block."
                    case .userToBlockNotFound:
                        isError = true
                        errorMessage = "You aren't authorized. Please try again later."
                    }
                    
                    if isError {
                        displayErrorMessage = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            displayErrorMessage = false
                        }
                    }
                }
            } label: {
                Text("Block \(tide.creatorUsername)")
            }
        } message: {
            Text("\n1. You won't see their Tides or messages anymore.\n\n2. You'll still be able to join the same Tides as long as neither of you are the creators.")
        }

    }
}

#Preview {
    AvailableTideListView(path: .constant([]))
}
