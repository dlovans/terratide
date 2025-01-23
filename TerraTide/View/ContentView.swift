//
//  ContentView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-01-21.
//

import SwiftUI

struct ContentView: View {
    //Change later to observe user object.
    private var isLoggedIn = false
    var body: some View {
        VStack {
            if !isLoggedIn {
                AuthView()
            } else {
                // display Menu View
            }
        }
    }
}

#Preview {
    ContentView()
}
