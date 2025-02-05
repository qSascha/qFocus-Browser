//
//  ContentView.swift
//  qFocus Browser
//
//  Created by Sascha on 2025-01-25.
//

import SwiftUI
import SwiftData




struct ContentView: View {
    @Query(
        filter: #Predicate<sitesStorage> { $0.siteName != ""},
        sort: \sitesStorage.siteOrder
    ) var webSites: [sitesStorage]
    @Query() var settingsDataArray: [settingsStorage]

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @Environment(\.modelContext) private var modelContext

    @StateObject var globals = GlobalVariables()
    @StateObject var viewModel = ContentViewModel()


    @AppStorage("onboardingComplete") var onboardingComplete: Bool = false



    var body: some View {
        ZStack {
            if let settingsData = settingsDataArray.first {
                MainContent()
                    .environmentObject(globals)
                    .environmentObject(viewModel)
            }
        }
        .onAppear {
            print("Main folder path: \(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.path ?? "Not found")")
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
    @Query(filter: #Predicate<adBlockFilters> { $0.enabled == true },
           sort: [SortDescriptor(\adBlockFilters.sortOrder, order: .reverse)]
    ) var enabledFilters: [adBlockFilters]

    @Query() var settingsDataArray: [settingsStorage]

    @EnvironmentObject var globals: GlobalVariables
    @EnvironmentObject var viewModel: ContentViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Navigation Bar
                if settingsDataArray[0].navOption == .freeFlow {
                    FloatingNavBar()
                } else {
                    NavBar()
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
            .background(Color("BackgroundColorTopBar"))
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
                    try await viewModel.initializeBlocker(isEnabled: settings.enableAdBlock, enabledFilters: enabledFilters)
                }
            }
        }
        .ignoresSafeArea(edges: {
            var edges: Edge.Set = []
            if !settingsDataArray[0].showTopBar { edges.insert(.top) }
            if !settingsDataArray[0].showBottomBar { edges.insert(.bottom) }
            return edges
        }())
    }
}



