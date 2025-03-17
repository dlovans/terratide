//
//  LoadingView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-02-15.
//

import SwiftUI

struct LoadingView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    // Adaptive colors based on color scheme
    private var gradientColors: [Color] {
        colorScheme == .dark ? 
            [Color(red: 0.7, green: 0.3, blue: 0.3), Color(red: 0.7, green: 0.4, blue: 0.2)] : 
            [Color(red: 0.95, green: 0.4, blue: 0.4), Color(red: 0.95, green: 0.6, blue: 0.3)]
    }
    
    private var progressTint: Color {
        .white
    }
    
    var body: some View {
        ZStack {
            // Modern gradient background
            LinearGradient(
                gradient: Gradient(colors: gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Fun pattern overlay
            ZStack {
                ForEach(0..<15) { i in
                    Circle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: CGFloat.random(in: 50...150))
                        .position(
                            x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                            y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                        )
                }
            }
            .ignoresSafeArea()
            
            // Loading indicator
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: progressTint))
                    .scaleEffect(1.5)
                
                Text("Loading...")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
            }
            .padding(30)
            .background(Color.black.opacity(0.15))
            .cornerRadius(20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

#Preview {
    LoadingView()
        .preferredColorScheme(.light)
}

#Preview {
    LoadingView()
        .preferredColorScheme(.dark)
}
