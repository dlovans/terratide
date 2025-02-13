//
//  ContentView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-01-21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    private var isBanned = false
    private var isNewUser = false
    var body: some View {
        VStack {
            if !authViewModel.isAuthenticated {
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
    let authViewModel = AuthViewModel()
    ContentView()
        .environmentObject(authViewModel)
}
