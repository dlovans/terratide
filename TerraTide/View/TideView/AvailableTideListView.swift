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
                if let userLocation = locationService.userLocation, let userId = userViewModel.user?.id {
                    tidesViewModel.attachAvailableTidesListener(for: userLocation, userId: userId)
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
            }
        }
        .sheet(isPresented: $showReportTideSheet) {
            Text(tide.id!)
        }
    }
}

#Preview {
    AvailableTideListView(path: .constant([]))
}
