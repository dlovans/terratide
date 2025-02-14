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
            if authViewModel.initialLoadComplete {
                if !authViewModel.isAuthenticated {
                    AuthView()
                } else {
                    if isBanned {
                        BanHammerView()
                    } else if isNewUser {
                        NewUserView()
                    } else {
                        MenuView()
                    }
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
