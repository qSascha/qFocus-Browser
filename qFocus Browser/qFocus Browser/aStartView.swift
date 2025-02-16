//
//  ContentView.swift
//  qFocus Browser
//
//  Created by Sascha on 2025-01-25.
//

import SwiftUI
import SwiftData




struct StartView: View {

    // for debugging
    @State private var hasInitialized = false

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>

    @StateObject private var startViewModel: StartViewModel
    @StateObject var globals = GlobalVariables()

    @AppStorage("onboardingComplete") var onboardingComplete: Bool = false





    init(modelContext: ModelContext) {
        _startViewModel = StateObject(wrappedValue : StartViewModel(modelContext: modelContext))
    }
    
    
    

    
    var body: some View {
        ZStack {
            MainContent()
                .environmentObject(globals)
                .environmentObject(startViewModel)
                .environmentObject(startViewModel.greasyScripts)
        }
        .onAppear {
            Task { @MainActor in
                if !hasInitialized {
                    await startViewModel.updateWebViewControllers(with: Array(startViewModel.webSites))
                    hasInitialized = true
                }
            }
        }
        .onChange(of: startViewModel.webSites) { oldSites, newSites in
            Task { @MainActor in
                await startViewModel.updateWebViewControllers(with: Array(newSites))
            }
        }
        .sheet(isPresented: .init(
//            get: { true },
            get: { !onboardingComplete },
            set: { if !$0 { onboardingComplete = true } }
        )) {
            iOSOnboarding()
                .interactiveDismissDisabled()
                .environmentObject(globals)
        }
    }
}




// Separate MainContent view for better organization
private struct MainContent: View {
    @Query(
        filter: #Predicate<sitesStorage> { $0.siteName != ""},
        sort: \sitesStorage.siteOrder
    ) var webSites: [sitesStorage]
    @Query(filter: #Predicate<adBlockFilters> { $0.enabled == true },
           sort: [SortDescriptor(\adBlockFilters.sortOrder, order: .reverse)]
    ) var enabledFilters: [adBlockFilters]

    @Query() var settingsDataArray: [settingsStorage]

    @StateObject private var authManager = AuthenticationManager()

    @Environment(\.modelContext) private var modelContext
    
    @EnvironmentObject var globals: GlobalVariables
    @EnvironmentObject var startViewModel: StartViewModel
    
    @AppStorage("onboardingComplete") var onboardingComplete: Bool = false

    
    
    
    
    

    var body: some View {

        //TODO: Find better solution
        if settingsDataArray.isEmpty {
            // Show loading or create default settings
            ProgressView("Initializing Settings...")
                .onAppear {
                    initializeDefaultSettings(context: modelContext)
                }
        } else {
            
            if authManager.isUnlocked || settingsDataArray[0].faceIDEnabled == false {
                
                
                GeometryReader { geometry in
                    ZStack {
                        // Navigation Bar
                        if settingsDataArray[0].showNavBar {
                            NavBar()
//                            NavBar(greasyScripts: startViewModel.greasyScripts)
                        } else {
                            FloatingNavBar()
//                            FloatingNavBar(greasyScripts: startViewModel.greasyScripts)
                        }
                        
                        // Loading screen for ad-blocker
                        if startViewModel.showAdBlockLoadStatus {
                            AdBlockLoadStatus()
                                .zIndex(1)
                        }
                        
                        // Web Views
                        WebViews()
                            .zIndex(0)
                    }
                    .background(Color(.qBlueLight))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .sheet(isPresented: $globals.showOptionsView) {
                        iOSOptionsView()
                            .presentationDetents([.large])
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                .onAppear {
                    // Enable Ad-Blocker, if onboarding finalized.
                    if let settings = settingsDataArray.first {
                        Task {
                            try await startViewModel.initializeBlocker(settings: settings, enabledFilters: enabledFilters, modelContext: modelContext, forceUpdate: false)
                        }
                    }
                }
                .onChange(of: onboardingComplete) { _, completed in
                    if completed {
                        if let settings = settingsDataArray.first {
                            Task {
                                print("Onboarding completed: Enabling ad blocker: \(settings.adBlockLastUpdate?.formatted() ?? "never")")
                                try await startViewModel.initializeBlocker(settings: settings, enabledFilters: enabledFilters, modelContext: modelContext, forceUpdate: false)
                            }
                        }
                    }
                }
                .sheet(isPresented: $globals.showShareSheet) {
                    if let url = URL(string: webSites[globals.currentTab].siteURL) {
                        ShareSheet(activityItems: [url])
                            .presentationDetents([.medium, .large])
                            .presentationDragIndicator(.visible)
                    }
                }
                
                
            } else {
                VStack {
                    Image(systemName: "faceid")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Use Face ID to unlock")
                        .padding()
                }
                .onAppear {
                    authManager.authenticate()
                }
            }
            
        }

        
        
        
    }
}



