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
    private var isBanned = false
    private var isNewUser = false
    var body: some View {
        VStack {
            if !isLoggedIn {
                AuthView()
            } else {
                if isBanned {
                    Text("Banned")
                } else if isNewUser {
                    Text("Create new username")
                } else {
                    MenuView()
                }
            }
        }
        .fontDesign(.monospaced)
    }
}

#Preview {
    ContentView()
}
