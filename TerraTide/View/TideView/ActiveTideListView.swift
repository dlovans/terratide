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
                                    path: $path
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
    
    @EnvironmentObject private var userViewModel: UserViewModel
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
                        .font(.system(size: 14))
                }
                
                HStack {
                    Button {
                        // Leave button, deactivating tide for this user.
                        // Left this tide...
                    } label: {
                        HStack {
                            Image(systemName: "arrow.backward")
                            Text("Leave")
                            
                        }
                        .frame(maxWidth: .infinity)
                        .padding(10)
                        .background(Color.red.opacity(0.7))
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        
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
                        .background(Color.orange)
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
            Text(tide.id!)
        }
    }
}

#Preview {
    ActiveTideListView(path: .constant([]))
}
