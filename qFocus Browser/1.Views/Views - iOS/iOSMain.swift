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
            // Top safe-area background, dynamically colored
            Color(viewModel.statusBarBackgroundColor)
                .ignoresSafeArea(edges: .top)
                .zIndex(-1)
            
            // Navigation Bar
            NavBar(coordinator: coordinator)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                .allowsHitTesting(true)
                .zIndex(5)

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
                    
/*
                FullScreenPulsingOverlay(color: .red)
                    .zIndex(9)
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
                    .transition(.opacity)

            FullScreenPulsingBorder(lineWidth: 20, color: .red)
                .zIndex(9)
                .allowsHitTesting(false)
                .ignoresSafeArea()
*/
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(edges: .bottom)
        .fullScreenCover(isPresented: $coordinator.showOptionsView) {
            iOSOptions()
        }
        .fullScreenCover(isPresented: $viewModel.showPrivacy) {
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



// MARK: - Full-screen Pulsing Overlay (non-blocking)
private struct FullScreenPulsingOverlay: View {
    let color: Color
    @State private var isPulsing = false
    
    var body: some View {
        Rectangle()
            .fill(color.opacity(isPulsing ? 0.15 : 0.45))
            .onAppear {
                withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
            .onDisappear {
                isPulsing = false
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



// MARK: - Full-screen Pulsing Border that follows screen curvature (heuristic)
private struct FullScreenPulsingBorder: View {
    let lineWidth: CGFloat
    let color: Color
    
    @State private var phase: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            // Heuristic: derive a radius from safe-area insets. This tends to match device corners well.
            let safe = geo.safeAreaInsets
            let inferredCorner = max(safe.top, max(safe.leading, safe.trailing))
            // Clamp to a sensible range for iPhone-like corners.
//            let estimatedRadius = max(30, min(70, inferredCorner == 0 ? 50 : inferredCorner))
            let estimatedRadius = CGFloat(60)
            
            RoundedRectangle(cornerRadius: estimatedRadius, style: .continuous)
                .inset(by: (lineWidth / 2) - 10)
                .stroke(
                    color.opacity(phase ? 0.25 : 1.0),
                    lineWidth: lineWidth
                )
//                .scaleEffect(phase ? 1.0 : 0.995, anchor: .center) // subtle pulse
                .frame(width: geo.size.width, height: geo.size.height)
                .animation(nil, value: geo.size)
                .onAppear {
                    print("InferredCorner: \(inferredCorner), EstimatedRadius: \(estimatedRadius)")
                    withAnimation(
                        .easeInOut(duration: 1.6)
                            .repeatForever(autoreverses: true)
                    ) {
                        phase = true
                    }
                }
                .onDisappear {
                    phase = false
                }
        }
    }
}
