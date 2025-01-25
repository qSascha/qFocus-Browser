//
//  qFocus_BrowserApp.swift
//  qFocus Browser
//
//  Created by Sascha on 2025-01-25.
//
import SwiftUI
import SwiftData






@main
struct Social_PrivacyApp: App {
    @StateObject private var globals = GlobalVariables()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [sitesStorage.self, settingsStorage.self], isAutosaveEnabled: false)
                .environmentObject(globals)
        }

    }
}
    
