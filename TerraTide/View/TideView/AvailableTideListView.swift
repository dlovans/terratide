//
//  TideView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-01-25.
//

import SwiftUI

struct AvailableTideListView: View {
    @EnvironmentObject private var tidesViewModel: TidesViewModel
    @EnvironmentObject private var locationService: LocationService
    @Binding var path: [Route]
    
    var body: some View {
        ZStack {
            if tidesViewModel.tidesHaveLoaded {
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
                            ForEach(tidesViewModel.tides) { tide in
                                TideItemView(tide: tide, path: $path)
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
                if let userLocation = locationService.userLocation {
                    tidesViewModel.attachTidesListener(for: userLocation)
                }
            }
        }
        .onDisappear {
            Task { @MainActor in
                tidesViewModel.removeTidesListener()
            }
        }
    }
}

struct TideItemView: View {
    let tide: Tide
    @Binding var path: [Route]
    
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
                        path.append(.tide(tide.id!))
                    } label: {
                        HStack {
                            Text(actionButtonText)
                            Image(systemName: "arrow.forward")
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(10)
                        .background(.orange)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        
                    }
                    .buttonStyle(RemoveHighlightButtonStyle())
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
            Text("Hello worlnknkd")
        }
    }
}

#Preview {
    AvailableTideListView(path: .constant([]))
}
