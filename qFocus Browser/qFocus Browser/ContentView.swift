//
//  ContentView.swift
//  qFocus Browser
//
//  Created by Sascha on 2025-01-25.
//

import SwiftUI
import SwiftData




struct ContentView: View {
    @Query() var settingsDataArray: [settingsStorage]
    @Query( filter: #Predicate<sitesStorage> { $0.siteName != ""},
        sort: \sitesStorage.siteOrder
    ) var webSites: [sitesStorage]



    // for debugging
    @State private var hasInitialized = false


    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @Environment(\.modelContext) private var modelContext

    @StateObject var globals = GlobalVariables()
    @StateObject var viewModel = ContentViewModel()

    @AppStorage("onboardingComplete") var onboardingComplete: Bool = false


    
    init() {
        _viewModel = StateObject(wrappedValue: ContentViewModel())
    }

    var body: some View {
        ZStack {
            MainContent()
                .environmentObject(globals)
                .environmentObject(viewModel)
        }
        .onAppear {
            Task { @MainActor in
                if !hasInitialized {
                    await viewModel.updateWebViewControllers(with: Array(webSites))
                    hasInitialized = true
                }
            }
        }
        .onChange(of: webSites) { oldSites, newSites in
            Task { @MainActor in
                await viewModel.updateWebViewControllers(with: Array(newSites))
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
    @EnvironmentObject var viewModel: ContentViewModel
    


    var body: some View {
        
        if authManager.isUnlocked || settingsDataArray[0].faceIDEnabled == false {

        
            GeometryReader { geometry in
                ZStack {
                    // Navigation Bar
                    if settingsDataArray[0].showNavBar {
                        NavBar(scriptManager: viewModel.scriptManager)
                    } else {
                        FloatingNavBar(scriptManager: viewModel.scriptManager)
                    }
                    
                    // Loading screen for ad-blocker
                    if viewModel.showAdBlockLoadStatus {
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
                    iOSOptionsView(viewModel: viewModel)
                        .presentationDetents([.large])
                }
            }
            .onAppear {
                // Enable Ad-Blocker, if onboarding finalized.
                if let settings = settingsDataArray.first {
                    Task {
                        try await viewModel.initializeBlocker(settings: settings, enabledFilters: enabledFilters, modelContext: modelContext, forceUpdate: false)
                    }
                }
            }
            .ignoresSafeArea(edges: .bottom)
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



