//
//  MenuView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-01-24.
//

import SwiftUI

struct MenuView: View {
    @Environment(\.colorScheme) private var colorScheme
    @State private var currentPage: Page = .availableTides
    
    var body: some View {
        // Root ZStack with fixed background
        GeometryReader { geometry in
            ZStack {
                // Modern gradient background - matching AuthView
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.95, green: 0.4, blue: 0.4), // Warm red
                        Color(red: 0.95, green: 0.6, blue: 0.3)  // Warm orange
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Fun pattern overlay - matching AuthView
                ZStack {
                    ForEach(0..<20) { i in
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: CGFloat.random(in: 50...150))
                            .position(
                                x: CGFloat.random(in: 0...geometry.size.width),
                                y: CGFloat.random(in: 0...geometry.size.height)
                            )
                    }
                }
                .ignoresSafeArea()
                
                // Main content with navigation
                VStack(spacing: 0) {
                    // Content area - changes based on selected page
                    ZStack {
                        if currentPage == .activeTides {
                            ActiveTideListView()
                                .transition(.opacity)
                        }
                        
                        if currentPage == .availableTides {
                            AvailableTideListView()
                                .transition(.opacity)
                        }
                        
                        if currentPage == .chat {
                            VStack {
                                Text("Chat View")
                                    .font(.title)
                                    .foregroundColor(.white)
                                
                                Text("This is where chat messages would appear")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding()
                            }
                            .transition(.opacity)
                        }
                        
                        if currentPage == .settings {
                            VStack {
                                Text("Settings View")
                                    .font(.title)
                                    .foregroundColor(.white)
                                
                                Text("This is where settings would appear")
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding()
                            }
                            .transition(.opacity)
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .background(Color.clear)
                    .padding(.horizontal)
                    
                    // Custom Tab Bar
                    CustomTabBar(currentPage: $currentPage)
                        .padding(.bottom, 8)
                }
                .background(Color.clear) // Ensure menu container is transparent
            }
        }
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var currentPage: Page
    @Environment(\.colorScheme) private var colorScheme
    
    private var selectedColor: Color {
        Color(red: 0.95, green: 0.4, blue: 0.4)
    }
    
    var body: some View {
        HStack(spacing: 0) {
            TabButton(
                icon: "wave.3.right",
                title: "Active",
                isSelected: currentPage == .activeTides,
                selectedColor: selectedColor
            ) {
                withAnimation {
                    currentPage = .activeTides
                }
            }
            
            TabButton(
                icon: "mappin.and.ellipse",
                title: "Available",
                isSelected: currentPage == .availableTides,
                selectedColor: selectedColor
            ) {
                withAnimation {
                    currentPage = .availableTides
                }
            }
            
            TabButton(
                icon: "message",
                title: "Chat",
                isSelected: currentPage == .chat,
                selectedColor: selectedColor
            ) {
                withAnimation {
                    currentPage = .chat
                }
            }
            
            TabButton(
                icon: "gearshape",
                title: "Settings",
                isSelected: currentPage == .settings,
                selectedColor: selectedColor
            ) {
                withAnimation {
                    currentPage = .settings
                }
            }
        }
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.2))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
        .padding(.horizontal)
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let selectedColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? selectedColor : .white.opacity(0.7))
                
                Text(title)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? selectedColor : .white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Enums
enum Page {
    case activeTides, availableTides, chat, settings
}

#Preview {
    MenuView()
        .preferredColorScheme(.light)
}

#Preview {
    MenuView()
        .preferredColorScheme(.dark)
}
