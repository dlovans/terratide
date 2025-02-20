//
//  ContentView.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-01-21.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var locationService: LocationService
    
    
    private var locationEnabled: Bool {
        locationService.locationAuthorized == .authorizedAlways || locationService.locationAuthorized == .authorizedWhenInUse
    }
    
    var body: some View {
        VStack {
            if authViewModel.initialLoadComplete && userViewModel.initialLoadComplete  {
                if !authViewModel.isAuthenticated {
                    AuthView()
                } else {
                    if userViewModel.userDataLoaded {
                        if let user = userViewModel.user {
                            if user.isBanned {
                                BanHammerView()
                            } else if user.username.isEmpty {
                                NewUserView()
                            } else if !locationEnabled {
                                LocationPermissionView()
                            } else {
                                if locationService.locationServicesLoaded {
                                    MenuView()
                                } else {
                                    LoadingView()
                                        .onAppear {
                                            Task { @MainActor in
                                                locationService.startPeriodicLocationTask()
                                            }
                                        }
                                }
                            }
                        }
                    } else {
                        LoadingView()
                    }
                }
            } else {
                LoadingView()
            }
        }
        .fontDesign(.monospaced)
    }
}

#Preview {
    let authViewModel = AuthViewModel()
    let userViewModel = UserViewModel()
    ContentView()
        .environmentObject(authViewModel)
        .environmentObject(userViewModel)
}
