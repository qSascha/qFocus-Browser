//
//  hExternalWebViewController.swift
//  qFocus Browser
//
//  Created by qSascha on 2025-02-01.
//

import SwiftUI
@preconcurrency import WebKit
import SwiftData





// MARK: - Wrapper for UIKit presentation
struct ExternalWebViewWrapper: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let webView = ExternalWebView(url: url)
        let hostingController = UIHostingController(rootView: webView)
        let navigationController = UINavigationController(rootViewController: hostingController)
        navigationController.modalPresentationStyle = .fullScreen
        
        hostingController.isModalInPresentation = true

        return navigationController
    }
    
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}

// MARK: - Main SwiftUI View
struct ExternalWebView: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss
    @StateObject private var webViewModel = WebViewModel()
    @State private var showShareSheet = false


    var body: some View {
        NavigationStack { 
            WebViewRepresentable(url: url, viewModel: webViewModel)
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color.qBlueLight, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("done_button".localized) {
                            // Try dismissing with animation
                            withAnimation {
                                dismiss()
                            }
                        }
                        .foregroundColor(.white)
                    }
                    
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: { webViewModel.goBack() }) {
                            Image(systemName: "chevron.backward")
                        }
                        .foregroundColor(.white)
                        .disabled(!webViewModel.canGoBack)
                        
                        Button(action: { webViewModel.goForward() }) {
                            Image(systemName: "chevron.forward")
                        }
                        .foregroundColor(.white)
                        .disabled(!webViewModel.canGoForward)
                        
                        Button(action: {showShareSheet = true} ) {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .foregroundColor(.white)
                        
                        Button(action: openInSafari) {
                            Image(systemName: "safari")
                        }
                        .foregroundColor(.white)
                    }
                }
                .sheet(isPresented: $showShareSheet) {
                    ShareSheet(activityItems: [url])
                        .presentationDetents([.medium, .large])
                        .presentationDragIndicator(.visible)
                }
        }
    }
    
    
    private func openInSafari() {
        UIApplication.shared.open(url)
    }
    
    // ShareSheet struct for UIActivityViewController
    struct ShareSheet: UIViewControllerRepresentable {
        let activityItems: [Any]
        
        func makeUIViewController(context: Context) -> UIActivityViewController {
            let controller = UIActivityViewController(
                activityItems: activityItems,
                applicationActivities: nil
            )
            return controller
        }
        
        func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
    }

}




// MARK: - WebView ViewModel
class WebViewModel: ObservableObject {
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    weak var webView: WKWebView?
    
    func goBack() {
        webView?.goBack()
    }
    
    func goForward() {
        webView?.goForward()
    }
    
    func updateNavigationState() {
        // Ensure updates happen on main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.canGoBack = self.webView?.canGoBack ?? false
            self.canGoForward = self.webView?.canGoForward ?? false
        }
    }
}




// MARK: - WebView Representable
struct WebViewRepresentable: UIViewRepresentable {
    let url: URL
    @ObservedObject var viewModel: WebViewModel
    
    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        configuration.processPool = WKProcessPool()
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        
        viewModel.webView = webView
        
        let request = URLRequest(url: url)
        webView.load(request)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(
            context.coordinator,
            action: #selector(Coordinator.handleRefresh),
            for: .valueChanged
        )
        webView.scrollView.refreshControl = refreshControl
        
        return webView
    }
    

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Call updateNavigationState after a brief delay to avoid view update cycle
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            viewModel.updateNavigationState()
        }
    }

    
/*
    func updateUIView(_ webView: WKWebView, context: Context) {
        viewModel.updateNavigationState()
    }
*/

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        var parent: WebViewRepresentable
        
        init(_ parent: WebViewRepresentable) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView,
                    decidePolicyFor navigationAction: WKNavigationAction,
                    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            decisionHandler(.allow)
        }
        
        func webView(_ webView: WKWebView,
                    createWebViewWith configuration: WKWebViewConfiguration,
                    for navigationAction: WKNavigationAction,
                    windowFeatures: WKWindowFeatures) -> WKWebView? {
            if let url = navigationAction.request.url {
                webView.load(URLRequest(url: url))
            }
            return nil
        }
        
        @objc func handleRefresh(_ sender: UIRefreshControl) {
            parent.viewModel.webView?.reload()
            sender.endRefreshing()
        }
    }
}


