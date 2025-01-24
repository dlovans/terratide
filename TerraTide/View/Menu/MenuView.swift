//
//  MenuView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-01-24.
//

import SwiftUI

struct MenuView: View {
    @State private var position = ScrollPosition(edge: .leading)
    @State private var currentPage = 1
    @State private var screenWidth = UIScreen.main.bounds.width
    var body: some View {
        ZStack {
            Color.purple
                .ignoresSafeArea()
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    // Change to actual menu items.
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .id(0)
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .id(1)
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .id(2)
                    //
                }
                .background {
                    GeometryReader { geometry in
                        Color.clear
                            .onChange(of: geometry.frame(in: .global).minX) { oldValue, newValue in
                                let calculatedPage = Int(round(-newValue / UIScreen.main.bounds.width))
                                if calculatedPage != currentPage {
                                    currentPage = calculatedPage
                                    print("Current Page: \(currentPage)")
                                }
                            }
                    }
                }
            }
            .scrollBounceBehavior(.always)
            .scrollPosition($position)
            .ignoresSafeArea()
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.paging)
        }
    }
}

#Preview {
    MenuView()
}
