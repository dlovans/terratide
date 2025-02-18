//
//  ActiveTidesView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-02.
//

import SwiftUI

struct ActiveTideListView: View {
    @Binding var path: [Route]
    
    let tides: [Tide] = [
        Tide(id: "0", title: "Dlovan's Psycho Game", description: "Jag ska irritera dig. Första person som blir arg är en n00b.", creatorId: "Dlovan", creatorUsername: "dsf", tideGroupSize: 10000, memberIds: ["Dlovan":"dlo", "Ibn":"asr"]),
        Tide(id: "1", title: "Chess Masters", description: "Tävling för schackspelare", creatorId: "Magnus", creatorUsername: "asds", tideGroupSize: 100, memberIds: ["Dlovan":"dlo", "Ibn":"asr"]),
        Tide(id: "2", title: "Swift Developers", description: "Diskutera Swift och iOS", creatorId: "AppleDev", creatorUsername: "asdsad", tideGroupSize: 500, memberIds: ["Dlovan":"dlo", "Ibn":"asr"])
    ]
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("My Tides")
                }
                ScrollView {
                    LazyVStack {
                        ForEach(tides, id: \.self) { tide in
                            ActiveTideItemView(
                                id: tide.id!,
                                creatorId: tide.creatorId,
                                title: tide.title,
                                description: tide.description,
                                participants: tide.memberIds.count,
                                maxParticipants: tide.tideGroupSize,
                                path: $path
                            )
                        }
                    }
                }
                .scrollIndicators(.hidden)
                .padding(.top, 10)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.top, 7)
        .padding()
    }
}

// Joined and created tides, sorted by time, descending order.
struct ActiveTideItemView: View {
    let id: String
    let creatorId: String
    let title: String
    let description: String
    let participants: Int
    let maxParticipants: Int
    let now = Date()

    @Binding var path: [Route]
    @State private var showReportTideSheet: Bool = false
    
    var body: some View {
        ZStack {
            VStack (spacing: 10) {
                Text(title)
                    .frame(maxWidth: .infinity,alignment: .leading)
                Divider()
                    .background(.gray)
                Text(description)
                    .frame(maxWidth: .infinity,alignment: .leading)
                Divider()
                    .background(.gray)
                HStack {
                    Text("Joined: ")
                    Spacer()
                    Image(systemName: "clock.fill")
                        .foregroundStyle(.orange)
                    Text(now, style: .time)
                        .font(.system(size: 12))
                    Text(now, style: .date)
                        .font(.system(size: 12))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Text("By: \(creatorId)")
                    Spacer()
                    Image(systemName: "person.fill")
                    Text("\(participants)/\(maxParticipants)")
                        .font(.system(size: 14))
                }
                HStack {
                    Text(now.addingTimeInterval(7200) < Date() ? "Closed" : "Closing: ")
                    Spacer()
                    Image(systemName: "clock.fill")
                        .foregroundStyle(now.addingTimeInterval(7200) < Date() ? .red : .orange)
                    Text(now.addingTimeInterval(7200), style: .time)
                        .font(.system(size: 12))
                    Text(now.addingTimeInterval(7200), style: .date)
                        .font(.system(size: 12))
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
                        // Join button opens tide page.
                        path.append(.tide(String(id)))
                        
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
            // If userId != creatorId, display these...
            Button {
                showReportTideSheet = true
            } label: {
                Text("Report")
            }
        }
        .sheet(isPresented: $showReportTideSheet) {
            Text("Report Tide")
        }
    }
}

#Preview {
    ActiveTideListView(path: .constant([]))
}
