//
//  ContentView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-01-21.
//

import SwiftUI

struct ContentView: View {
    //Change later to observe user object.
    private var isLoggedIn = true
    var body: some View {
        VStack {
            if !isLoggedIn {
                AuthView()
            } else {
                MenuView()
            }
        }
    }
}

#Preview {
    ContentView()
}
