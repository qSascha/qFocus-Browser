//
//  OptionsGreasyWiz2-VM.swift
//  qFocus Browser
//
//
import Foundation
import WebKit
import SwiftUI



@MainActor
final class GreasyBrowserVM: NSObject, ObservableObject {
    @Published var webView: WKWebView
    @Published var url: URL
    @Published var detectedUserScriptPage: Bool = false
    
    
    
    //MARK: Init
    init(url: URL) {
        self.url = url

        let config = WKWebViewConfiguration()
        config.websiteDataStore = .nonPersistent()
        config.allowsInlineMediaPlayback = true
        
        self.webView = WKWebView(frame: .zero, configuration: config)
        
        super.init()
        
        self.webView.allowsBackForwardNavigationGestures = true
        self.webView.scrollView.bounces = true
        self.webView.scrollView.refreshControl = UIRefreshControl()

        self.webView.scrollView.refreshControl?.addTarget(
            self,
            action: #selector(reload),
            for: .valueChanged
        )

        self.webView.load(URLRequest(url: url))
        
        webView.navigationDelegate = self

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



//MARK: Navigation Delegate
extension GreasyBrowserVM: WKNavigationDelegate {
   
    
    @objc
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        preferences: WKWebpagePreferences,
        decisionHandler: @escaping @MainActor @Sendable (WKNavigationActionPolicy, WKWebpagePreferences) -> Void
    ) {
        // Only process user-initiated taps
        guard navigationAction.navigationType == .linkActivated,
              let url = navigationAction.request.url,
              let scheme = url.scheme?.lowercased() else {
            // Allow all other navigations (including JS, redirects, etc.)
            decisionHandler(.allow, preferences)
            return
        }

        // Handle mailto:, tel:, etc. externally
        let externalSchemes = ["mailto", "tel", "sms", "maps", "facetime"]
        if externalSchemes.contains(scheme) {
            UIApplication.shared.open(url)
            decisionHandler(.cancel, preferences)
            return
        }

        // Only handle http(s) links in the following logic
        guard scheme == "http" || scheme == "https" else {
            decisionHandler(.allow, preferences)
            return
        }

        // Compare domain for internal/external navigation
        guard let targetHost = url.host,
              let currentHost = webView.url?.host else {
            decisionHandler(.allow, preferences)
            return
        }
        let currentMainDomain = getDomainCore(currentHost)
        let targetMainDomain = getDomainCore(targetHost)

        if currentMainDomain == targetMainDomain {
            print("URL: \(url)")
            let request = URLRequest(url: url)
            decisionHandler(.cancel, preferences)
            webView.load(request)
            return
        } else {
            decisionHandler(.allow, preferences)
            return
        }
    }




    
    
    

    /// Handles requests to create a new web view (e.g., for popups).
    /// Instead of creating a new window, this method either loads the URL in the current web view
    /// if it's in the same domain, or presents it in an external view if it's from a different domain.
    /// This approach maintains the focus-oriented browsing experience.
    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {

        
        webView.load(navigationAction.request)
        return nil
    }

    
}





