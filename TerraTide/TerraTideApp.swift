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

    var body: some Scene {
        WindowGroup {
            ContentView()
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
