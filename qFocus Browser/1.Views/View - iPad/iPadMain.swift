//
//  iPadMain.swift
//  qFocus Browser
//
//
import SwiftUI
import WebKit
import FactoryKit



struct iPadMain: View {
    @InjectedObject(\.mainVM) var viewModel: MainVM
    @InjectedObject(\.navigationVM) var navVM: NavigationVM
    @InjectedObject(\.optionsVM) var optionsVM: OptionsVM
    @InjectedObject(\.adBlockUC) var adBlockUC: AdBlockFilterUC
    
    @StateObject private var coordinator = AppCoordinator()
    
    
    
    var body: some View {
        
        ZStack {
            
            iOSResume()
                .zIndex(optionsVM.faceIDEnabled && viewModel.showPrivacy ? 6 : 4)

            ZStack {
                // Top safe-area background, dynamically colored
                Color(viewModel.statusBarBackgroundColor)
                    .ignoresSafeArea(edges: .top)
                    .zIndex(-1)
                
                // Navigation Bar
                NavBar(coordinator: coordinator)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .zIndex(5)
                
                // Loading message for ad-blocker
                if adBlockUC.updatingFilters {
                    AdBlockLoadStatus()
                        .zIndex(1)
                        .allowsHitTesting(false)
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
                .zIndex(2)
                .onAppear {
                    Task {
                        await viewModel.loadAllWebViews()
                        viewModel.updateTopAreaColor()
                    }
                }
                
                if viewModel.disableEB {
                    TopBarPulsingOverlay(color: .red)
                        .zIndex(1)
                    
                }
                
            }
            .zIndex(5)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: .bottom)
            .fullScreenCover(isPresented: $coordinator.showOptionsView) {
                iPadOptions()
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
}



// MARK: - Top Bar Pulsing Overlay for status bar area
private struct TopBarPulsingOverlay: View {
    let color: Color
    @State private var isPulsing = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                Rectangle()
                    .fill(color.opacity(isPulsing ? 0.1 : 1.0))
                    .frame(width: 1000, height: 100)
                    .aspectRatio(contentMode: ContentMode.fit)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                            isPulsing = true
                        }
                    }
                    .onDisappear {
                        isPulsing = false
                    }
                
                Spacer()
            }
        }
        .ignoresSafeArea(edges: .top)
    }
}


