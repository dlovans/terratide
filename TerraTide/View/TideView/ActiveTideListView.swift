//
//  ActiveTidesView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-02.
//

import SwiftUI

struct ActiveTideListView: View {
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    Text("My Tides")
                        .font(.title2)
                }
                ScrollView {
                    LazyVStack {
                        ActiveTideItemView()
                        ActiveTideItemView()
                        ActiveTideItemView()
                        ActiveTideItemView()
                        ActiveTideItemView()
                        ActiveTideItemView()
                        ActiveTideItemView()
                        
                    }
                }
                .scrollIndicators(.hidden)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 7)
    }
}

// Joined and created tides, sorted by time, descending order.
struct ActiveTideItemView: View {
    var body: some View {
        ZStack {
            VStack (spacing: 10) {
                Text("Dlovan's psycho game")
                    .font(.title3)
                    .frame(maxWidth: .infinity,alignment: .leading)
                Divider()
                    .background(.gray)
                Text("Jag ska irritera dig. Första person som blir arg är en n00b.")
                    .frame(maxWidth: .infinity,alignment: .leading)
                Divider()
                    .background(.gray)
                HStack {
                    Text("Joined: ")
                    Spacer()
                    Image(systemName: "clock.fill")
                        .foregroundStyle(.orange)
                    Text(Date(), style: .time)
                    Text(Date(), style: .date)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Text("@Dlovan")
                    Spacer()
                    Image(systemName: "person.fill")
                    Text("9999/10000")
                }
                HStack {
                    Text("Expires in:")
                    Text("5 hours")
                    Spacer()
                }
                HStack {
                    Button {
                        // Leave button, deactivating tide for this user.
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
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color.gray.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    ActiveTideListView()
}
