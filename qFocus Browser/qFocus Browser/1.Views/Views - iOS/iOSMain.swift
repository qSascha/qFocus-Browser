//
//  iOSMain.swift
//  qFocus Browser
//
//
import SwiftUI
import WebKit
import FactoryKit



struct iOSMain: View {
    @InjectedObject(\.mainVM) var viewModel: MainVM
    @InjectedObject(\.navigationVM) var navVM: NavigationVM
    @InjectedObject(\.optionsVM) var optionsVM: OptionsVM
    @InjectedObject(\.adBlockUC) var adBlockUC: AdBlockFilterUC

    @StateObject private var coordinator = AppCoordinator()



    var body: some View {
        
        
        ZStack {
            // Navigation Bar
            NavBar(coordinator: coordinator)

/*
            if optionsVM.showNavBar {
                NavBar(coordinator: coordinator)
            } else {
                FloatingNavBar(coordinator: coordinator)
            }
*/
            // Loading message for ad-blocker
            if adBlockUC.updatingFilters {
                 AdBlockLoadStatus()
                     .zIndex(1)
             }


            // Web Views
            VStack {
/*
                if (optionsVM.showNavBar) {
                    Rectangle()
                        .opacity(0)
                        .frame(maxWidth: .infinity, maxHeight: 30)
                }
*/
                ZStack {
                    // Simply shows ZStack of WebView Views.
                    // Binds selectedWebViewID to control which one is visible.
                    // No knowledge of how web views are created, loaded, or configured.

                    ForEach(viewModel.sitesDetails.map { $0 }, id: \.id) { item in
                        WebView(viewModel: item.viewModel)
                            .opacity(viewModel.selectedWebViewID == item.id ? 1 : 0)
                    }

                }
            }
            .onAppear {
                Task {
                    await viewModel.loadAllWebViews()
                }
            }

        }
//        .background(Color(.qBlueLight))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .bottom)
        .fullScreenCover(isPresented: $coordinator.showOptionsView) {
            iOSOptions()
        }
        .sheet(isPresented: $coordinator.showShareSheet) {
            //TODO: Replace with correct URL
            if let url = URL(string: "https://reddit.com") {
                //TODO: Share current URL
                ShareSheet(activityItems: [url])
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .onAppear {
           adBlockUC.compileAdBlockLists()
        }
        .sheet(item: $viewModel.externalURL, onDismiss: {
            viewModel.externalURL = nil
        }) { identifiable in
            ExternalBrowserView(viewModel: ExternalBrowserVM(url: identifiable.url))
        }
    }
    
}
