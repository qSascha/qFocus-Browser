//
//  qFocus_BrowserApp.swift
//  qFocus Browser
//
//  Created by Sascha on 2025-01-25.
//
import SwiftUI
import SwiftData
import CloudKit



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
                    adBlockFilterSetting.self,
                    greasyScriptSetting.self,
                    collectorModel.self
                ])
                , cloudKitDatabase: .none
            )


            // Initialize the container with configuration
            modelContainer = try ModelContainer(
                for: sitesStorage.self,
                settingsStorage.self,
                adBlockFilterSetting.self,
                greasyScriptSetting.self,
                collectorModel.self,
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
@main
struct qFocus_BrowserApp: App {
    let localContainer: ModelContainer
    
    init() {
        do {
            // Create configuration without autosave
            let localConfiguration = ModelConfiguration(
                schema: Schema([
                    sitesStorage.self,
                    settingsStorage.self,
                    adBlockFilterSetting.self,
                    greasyScriptSetting.self
                ])
            )
            
            // Initialize the container with configuration
            localContainer = try ModelContainer(
                for: sitesStorage.self,
                settingsStorage.self,
                adBlockFilterSetting.self,
                greasyScriptSetting.self,
                configurations: localConfiguration
            )

            // Disable autosave on the context level
            localContainer.mainContext.autosaveEnabled = false

        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            StartView(modelContext: localContainer.mainContext)
                .modelContainer(localContainer)
        }
    }
}
*/





