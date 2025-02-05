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
        Tide(id: 0, title: "Dlovan's Psycho Game", description: "Jag ska irritera dig. Första person som blir arg är en n00b.", creator: "@Dlovan", participants: 9999, maxParticipants: 10000),
        Tide(id: 1, title: "Chess Masters", description: "Tävling för schackspelare", creator: "@Magnus", participants: 50, maxParticipants: 100),
        Tide(id: 2, title: "Swift Developers", description: "Diskutera Swift och iOS", creator: "@AppleDev", participants: 120, maxParticipants: 500)
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
                                .font(.largeTitle)
                        }
                }
                .font(.title2)
                .padding(.horizontal, 5)

                ScrollView {
                    LazyVStack {
                        ForEach(tides, id: \.self) { tide in
                            TideItemView(path: $path, tide: tide)
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}

struct TideItemView: View {
    @Binding var path: [Route]
    let tide: Tide
    
    var body: some View {
        ZStack {
            VStack (spacing: 10) {
                Text(tide.title)
                    .font(.title3)
                    .frame(maxWidth: .infinity,alignment: .leading)
                Divider()
                    .background(.gray)
                Text(tide.description)
                    .frame(maxWidth: .infinity,alignment: .leading)
                Divider()
                    .background(.gray)
                HStack {
                    Text(tide.creator)
                    Spacer()
                    Image(systemName: "person.fill")
                    Text("\(tide.participants)/\(tide.maxParticipants)")
                    
                }
                HStack {
                    Button {
                        print("clicked")
                        // Join button opens tide page.
                        path.append(.tide(tide))
                    } label: {
                        HStack {
                            Text("Join")
                            Image(systemName: "arrow.forward")
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    .blur(radius: 5)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    AvailableTideListView(path: .constant([]))
}
