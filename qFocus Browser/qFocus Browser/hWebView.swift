//
//  hWebView.swift
//  qFocus Browser
//
//  Created by Sascha on 2025-01-04.
//
import WebKit
import SwiftUI

// MARK: Content Blocking Web View Controller
class ContentBlockingWebViewController: UIViewController {
    private var webView: WKWebView!
    private var refreshControl: UIRefreshControl!
    
    // Initialize the ScriptManager with the script URL
    private let scriptURL = URL(string: "https://github.com/zbluebugz/facebook-clean-my-feeds/raw/main/greasyfork-release/fb-clean-my-feeds.user.js")!
    private lazy var scriptManager = ScriptManager(scriptURL: scriptURL)
    
    override func loadView() {
        super.loadView()
        
        // Create a unique configuration for each web view
        let configuration = WKWebViewConfiguration()
        
        // Get the app group container URL
        let containerPath = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        )[0].appendingPathComponent("WebViewData")
        
        // Create directory if it doesn't exist
        try? FileManager.default.createDirectory(
            at: containerPath,
            withIntermediateDirectories: true
        )
        
        // Set up the configuration
        let processPool = WKProcessPool()
        configuration.processPool = processPool
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        
        // Create the web view with the configuration
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view = webView
    }
    
    override func viewDidLoad() {
// This function is never being called don't use it.
// Instead use the init function in ContentViewModel class
        super.viewDidLoad()
//        setupWebView()
//        setupRefreshControl()
//        loadAndInjectScript()
    }
    
    public func setupWebView() {
        let configuration = WKWebViewConfiguration()
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.bounces = true
        view.addSubview(webView)
    }
    
    public func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshWebView(_:)), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl
    }
    
    @objc private func refreshWebView(_ sender: UIRefreshControl) {
        webView.reload()
        sender.endRefreshing()
    }
    
    func addContentRules(with ruleLists: [WKContentRuleList]) async throws {
        guard let webView = self.webView else {
            print("Warning: WebView not initialized in addContentRules")
            return
        }
        
        await MainActor.run {
            ruleLists.forEach { ruleList in
                webView.configuration.userContentController.add(ruleList)
            }
        }
    }
    
    // Updated to replace all rules
    func setupContentRules(with ruleLists: [WKContentRuleList]?) async throws {
        await MainActor.run {
            guard let webView = self.webView else {
                print("Warning: WebView not initialized")
                return
            }
            webView.configuration.userContentController.removeAllContentRuleLists()
            
            ruleLists?.forEach { ruleList in
                webView.configuration.userContentController.add(ruleList)
            }
        }
    }
    
    // Remove all Content Rule Lists
    func removeContentRules() async throws {
        await MainActor.run {
            guard let webView = self.webView else {
                print("Warning: WebView not initialized")
                return
            }
            webView.configuration.userContentController.removeAllContentRuleLists()
        }
    }
    
    func load(url: URL) {
        guard let webView = self.webView else {
            print("Warning: WebView not initialized")
            return
        }
        webView.load(URLRequest(url: url))
    }
    
    func getWebView() -> WKWebView? {
        return webView
    }
    
    public func loadAndInjectScript() {
        scriptManager.loadScript { [weak self] script in
            guard let self = self, let script = script else {
                print("Script loading failed - self or script is nil")
                return
            }
            
            DispatchQueue.main.async {
                self.scriptManager.injectScriptIntoWebView(webView: self.webView, script: script)
            }
        }
    }
/*
    // WKScriptMessageHandler method to receive messages from JavaScript
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "jsHandler", let messageBody = message.body as? String {
            print("JavaScript message: \(messageBody)")
        }
    }
*/
}





// MARK: Web View Container
struct WebViewContainer: UIViewControllerRepresentable {
    let webViewController: ContentBlockingWebViewController
    
    func makeUIViewController(context: Context) -> ContentBlockingWebViewController {
        return webViewController
    }
    
    func updateUIViewController(_ webViewController: ContentBlockingWebViewController, context: Context) {
        // Any updates to the view controller can be handled here
    }
}




