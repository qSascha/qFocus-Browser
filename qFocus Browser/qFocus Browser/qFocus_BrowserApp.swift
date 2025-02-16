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
    let modelContainer: ModelContainer
    
    init() {
        do {
            // Create configuration without autosave
            let configuration = ModelConfiguration(
                schema: Schema([
                    sitesStorage.self,
                    settingsStorage.self,
                    adBlockFilters.self,
                    greasyScripts.self
                ])
            )
            
            // Initialize the container with configuration
            modelContainer = try ModelContainer(
                for: sitesStorage.self,
                settingsStorage.self,
                adBlockFilters.self,
                greasyScripts.self,
                configurations: configuration
            )

            // Disable autosave on the context level
            modelContainer.mainContext.autosaveEnabled = false

        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            StartView(modelContext: modelContainer.mainContext)
                .modelContainer(modelContainer)
        }
    }
}






/*
struct qFocus_BrowserApp: App {
    
    var body: some Scene {
        WindowGroup {
            StartView()
                .modelContainer(for: [sitesStorage.self, settingsStorage.self, adBlockFilters.self, greasyScripts.self], isAutosaveEnabled: false)
        }
    }
}
*/


