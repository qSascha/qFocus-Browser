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

            // Loading message for ad-blocker
            if adBlockUC.updatingFilters {
                 AdBlockLoadStatus()
                     .zIndex(1)
             }


            // Web Views
            ZStack {
                // Simply shows ZStack of WebView Views.
                // Binds selectedWebViewID to control which one is visible.

                ForEach(viewModel.sitesDetails.map { $0 }, id: \.id) { item in
                    WebView(viewModel: item.viewModel)
                        .opacity(viewModel.selectedWebViewID == item.id ? 1 : 0)
                }

            }
            .onAppear {
                Task {
                    await viewModel.loadAllWebViews()
                }
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .bottom)
        .fullScreenCover(isPresented: $coordinator.showOptionsView) {
            iOSOptions()
        }
        .fullScreenCover(isPresented: $viewModel.isResuming) {
            iOSResume()
        }
        .sheet(isPresented: $coordinator.showShareSheet) {
            if let selectedID = viewModel.selectedWebViewID,
               let siteDetail = viewModel.sitesDetails.first(where: { $0.id == selectedID }),
               let url = siteDetail.viewModel.currentURL {
                ShareSheet(activityItems: [url])
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.visible)
            }
        }
        .onAppear {
            adBlockUC.compileAdBlockLists(manually: false)
        }
        .sheet(item: $viewModel.externalURL, onDismiss: {
            viewModel.externalURL = nil
        }) { identifiable in
            ExternalBrowserView(viewModel: ExternalBrowserVM(url: identifiable.url))
        }
    }
    
}
