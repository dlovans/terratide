//
//  TideView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-01-25.
//

import SwiftUI

struct AvailableTideListView: View {
    @Binding var path: [Route]
    
    let tides: [Tide] = [
        Tide(id: "0", title: "Dlovan's Psycho Game", description: "Jag ska irritera dig. Första person som blir arg är en n00b.", creatorId: "Dlovan", participants: 9999, maxParticipants: 10000, joinedUsers: ["Dlovan", "Ibn"]),
        Tide(id: "1", title: "Chess Masters", description: "Tävling för schackspelare", creatorId: "Magnus", participants: 50, maxParticipants: 100, joinedUsers: ["Dlovan", "Ibn"]),
        Tide(id: "2", title: "Swift Developers", description: "Diskutera Swift och iOS", creatorId: "AppleDev", participants: 120, maxParticipants: 500, joinedUsers: ["Dlovan", "Ibn"])
    ]
    
    var body: some View {
        ZStack {
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
                        ForEach(tides, id: \.self) { tide in
                            TideItemView(tide: tide, path: $path)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}

struct TideItemView: View {
    let tide: Tide

    @Binding var path: [Route]
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
                    Text("By: \(tide.creatorId)")
                    Spacer()
                    Image(systemName: "person.fill")
                    Text("\(tide.participants)/\(tide.maxParticipants)")
                }
                HStack {
                    Text("Expires in:")
                    Spacer()
                    Text(Date.now.addingTimeInterval(500), style: .timer)
                }
                
                HStack {
                    Button {
                        path.append(.tide(String(tide.id)))
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
            // If userId != creatorId, display these...
            Button {
                showReportTideSheet = true
            } label: {
                Text("Report")
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
