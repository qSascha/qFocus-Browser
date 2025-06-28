//
//  ExternalBrowser-VM.swift
//  qFocus Browser
//
//
import Foundation
import WebKit



@MainActor
final class ExternalBrowserVM: ObservableObject {
    @Published var webView: WKWebView
    @Published var url: URL

    
    
    //MARK: Init
    init(url: URL) {
        self.url = url

        let config = WKWebViewConfiguration()
        config.websiteDataStore = .nonPersistent() // New cookie store per instance
        config.allowsInlineMediaPlayback = true

        self.webView = WKWebView(frame: .zero, configuration: config)
        self.webView.allowsBackForwardNavigationGestures = true
        self.webView.scrollView.bounces = true
        self.webView.scrollView.refreshControl = UIRefreshControl()

        self.webView.scrollView.refreshControl?.addTarget(
            self,
            action: #selector(reload),
            for: .valueChanged
        )

        self.webView.load(URLRequest(url: url))
    }

    
    
    //MARK: Reload
    @objc private func reload() {
        webView.reload()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.webView.scrollView.refreshControl?.endRefreshing()
        }
    }

    
    
    //MARK: Can Go Back
    var canGoBack: Bool {
        webView.canGoBack
    }

    
    
    //MARK: Go Back or Close
    func goBackOrClose(_ onClose: () -> Void) {
        if webView.canGoBack {
            webView.goBack()
        } else {
            onClose()
        }
    }

    
    
    //MARK: Share Sheet Items
    func shareSheetItems() -> [Any] {
        [webView.url?.absoluteString ?? url.absoluteString]
    }
}
