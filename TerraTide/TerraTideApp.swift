//
//  TerraTideApp.swift
//  TerraTide
//
//  Created by Dlovan Sharif on 2025-01-21.
//

import SwiftUI
import FirebaseCore

@main
struct TerraTideApp: App {
    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate
    
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var userViewModel = UserViewModel()
    @StateObject private var locationService = LocationService()
    @StateObject private var chatViewModel = ChatViewModel()
    @StateObject private var singleTideViewModel = SingleTideViewModel()
    @StateObject private var tidesViewModel = TidesViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
                .environmentObject(userViewModel)
                .environmentObject(locationService)
                .environmentObject(chatViewModel)
                .environmentObject(singleTideViewModel)
                .environmentObject(tidesViewModel)
        }
    }
}


class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        .portrait
    }
}
