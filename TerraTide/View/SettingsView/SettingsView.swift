//
//  SettingsView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-09.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                Text("Settings")
                    .font(.title2)
                Button {
                    // Feedback sheet
                } label: {
                    HStack {
                        Text("Feedback")
                        Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.green.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                Button {
                    // Blocked users...to unblock
                } label: {
                    HStack {
                        Text("Blocked Users")
                        Image(systemName: "arrow.forward")
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.red.opacity(0.4))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
                Button {
                    // Log out
                } label: {
                    HStack {
                        Text("Logout")
                        Image(systemName: "square.and.arrow.down")
                            .rotationEffect(.degrees(-90))
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                
            }
            .buttonStyle(RemoveHighlightButtonStyle())
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
    }
}

#Preview {
    SettingsView()
}
