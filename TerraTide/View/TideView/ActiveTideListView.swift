//
//  ActiveTideListView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-02.
//

import SwiftUI

struct ActiveTideListView: View {
    @Binding var path: [Route]
    
    @EnvironmentObject private var tidesViewModel: TidesViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @State private var openingOrLeavingTide: Bool = false
    
    let tides: [Tide] = [
    ]
    
    var body: some View {
        ZStack {
            if tidesViewModel.activeTidesHaveLoaded {
                VStack {
                    HStack {
                        Text("My Tides")
                    }
                    ScrollView {
                        LazyVStack {
                            ForEach(tidesViewModel.activeTides, id: \.self) { tide in
                                ActiveTideItemView(
                                    tide: tide,
                                    path: $path,
                                    openingOrLeavingTide: $openingOrLeavingTide
                                )
                            }
                        }
                    }
                    .scrollIndicators(.hidden)
                    .padding(.top, 10)
                }
            } else {
                LoadingView()
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.top, 7)
        .padding()
        .onAppear {
            openingOrLeavingTide = false
            Task { @MainActor in
                if let userId = userViewModel.user?.id {
                    tidesViewModel.attachActiveTidesListener(userId: userId)
                }
            }
        }
        .onDisappear {
            Task { @MainActor in
                tidesViewModel.removeActiveTidesListener()
            }
        }
    }
}

// Joined and created tides, sorted by time, descending order.
struct ActiveTideItemView: View {
    let tide: Tide

    @Binding var path: [Route]
    @Binding var openingOrLeavingTide: Bool
    
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var singleTideViewModel: SingleTideViewModel
    @State private var showReportTideSheet: Bool = false
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
                        .font(.system(size: 14))
                }
                
                HStack {
                    Button {
                        Task { @MainActor in
                            openingOrLeavingTide = true
                            let status  = await singleTideViewModel.leaveTide(tideId: tide.id ?? "", userId: userViewModel.user?.id ?? "")
                            
                            var isError: Bool = false
                            
                            switch status {
                            case .left:
                                print("Successfully left Tide.")
                            case .invalidData:
                                errorMessage = "Failed to leave :("
                                isError = true
                            case .noDocument:
                                errorMessage = "Couldn't find Tide :("
                                isError = true
                            case .notMember:
                                errorMessage = "You're not a member of this Tide"
                                isError = true
                            case .failed:
                                errorMessage = "Failed to leave, something went wrong. :("
                                isError = true
                            }
                
                            if isError {
                                displayErrorMessage = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    displayErrorMessage = false
                                }
                            }
                            
                            openingOrLeavingTide = false
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.backward")
                            Text("Leave")
                            
                        }
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(openingOrLeavingTide ? .gray : Color.red.opacity(0.7))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .disabled(openingOrLeavingTide)
                        
                    }
                    .buttonStyle(RemoveHighlightButtonStyle())
                    Button {
                        path.append(.tide(tide.id!))
                    } label: {
                        HStack {
                            Text("Open")
                            Image(systemName: "arrow.forward")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(openingOrLeavingTide ? .gray : .orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        
                    }
                    .buttonStyle(RemoveHighlightButtonStyle())
                    .disabled(openingOrLeavingTide)
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
                .animation(.easeInOut, value: displayErrorMessage)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .background(.white)
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
            ReportView(reportType: .tide, tideId: tide.id ?? "", reportByUserId: userViewModel.user?.id ?? "", reportAgainstUserId: tide.creatorId, showReportSheet: $showReportTideSheet)
        }
    }
}

#Preview {
    ActiveTideListView(path: .constant([]))
}
