//
//  WebViews.swift
//  qFocus Browser
//
//
import SwiftUI
import WebKit
import FactoryKit



//MARK: Web View
struct WebView: View {
    @ObservedObject var viewModel: WebViewVM

    var body: some View {
        WebViewRepresentable(webView: viewModel.getWebView(), viewModel: viewModel)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: .bottom)

    }
    
}



//MARK: Web View Representable
struct WebViewRepresentable: UIViewRepresentable {
    let webView: WKWebView
    let viewModel: WebViewVM
    


    func makeUIView(context: Context) -> WKWebView {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(context.coordinator, action: #selector(Coordinator.handleRefresh), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl
        webView.allowsBackForwardNavigationGestures = true
        return webView
    }
    


    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Hook into view updates here if needed
    }
    
    
    //MARK: Pull-Down-to-Reload
    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel, webView: webView)
    }
    


    class Coordinator {
        let viewModel: WebViewVM
        let webView: WKWebView
        

        init(viewModel: WebViewVM, webView: WKWebView) {
            self.viewModel = viewModel
            self.webView = webView
        }


        @objc func handleRefresh(_ sender: UIRefreshControl) {
            let vm = viewModel
            Task { @MainActor in
                vm.reload()
                sender.endRefreshing()
            }
        }

        
    }

    
}


