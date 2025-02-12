//
//  qFocus_BrowserApp.swift
//  qFocus Browser
//
//  Created by Sascha on 2025-01-25.
//
import SwiftUI
import SwiftData




@main
struct qFocus_BrowserApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [sitesStorage.self, settingsStorage.self, adBlockFilters.self], isAutosaveEnabled: false)
        }
    }
}



