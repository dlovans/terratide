//
//  ChatIntroView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-04-02.
//

import SwiftUI

struct ChatIntroView: View {
    @State private var showChatView = false
    
    // Chat rules
    private let chatRules = [
        "Be respectful to all participants in the chat",
        "Dating and romantic solicitation is strictly prohibited",
        "No illicit activities or discussions of illegal content",
        "No hate speech, harassment, or bullying"
    ]
    
    var body: some View {
        // Match structure of AvailableTideListView
        VStack {
            // Title section like in AvailableTideListView
            HStack {
                Text("Chat")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
            }
            
            // Main scrollable content
            ScrollView {
                VStack(spacing: 25) {
                    // Chat icon
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 70, height: 70)
                        .foregroundColor(.white.opacity(0.9))
                    
                    // Introduction text
                    Text("Connect with other users in your area through the TerraTide chat feature.")
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal)
                    
                    // Rules section
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Chat Rules")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(chatRules, id: \.self) { rule in
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(Color.yellow)
                                        .font(.system(size: 14))
                                    
                                    Text(rule)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.9))
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.black.opacity(0.2))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Start chat button - Always enabled now
                    Button {
                        showChatView = true
                    } label: {
                        Text("Start Chatting")
                            .fontWeight(.semibold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color(red: 0.3, green: 0.6, blue: 0.9))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .shadow(color: Color(red: 0.3, green: 0.6, blue: 0.9).opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal)
                    .padding(.top, 5)
                    .padding(.bottom, 20)
                }
                .padding(.top, 10)
            }
            .scrollIndicators(.hidden)
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(.top, 7)
        .padding(.bottom, 20)
        .background(Color.clear) // Ensure background is transparent
        
        // Present ChatView as a fullScreenCover when button is pressed
        .fullScreenCover(isPresented: $showChatView) {
            ChatView()
        }
    }
}

#Preview {
    ChatIntroView()
}
