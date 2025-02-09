//
//  ContentBlockingWebViewController.swift
//  qFocus Browser
//
//  Created by qSascha on 2025-02-01.
//

import WebKit
import UIKit
import SwiftUI




class ContentBlockingWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    var webView: WKWebView!
    private var refreshControl: UIRefreshControl!
    private var hasSetupWebView = false

    @Environment(\.modelContext) private var modelContext
    
    override func loadView() {
        super.loadView()
        if !hasSetupWebView {
            setupWebView()
            setupRefreshControl()
            hasSetupWebView = true
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set both delegates for the webView
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        // Print confirmation of delegate setup
        print("🔧 ContentBlockingWebViewController: Delegates set up")
    }
    
    


    //MARK: Setup Web View
    func setupWebView() {
        let configuration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        configuration.userContentController = contentController
        
        let processPool = WKProcessPool()
        configuration.processPool = processPool
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        
        // Setup scroll view properties
        webView.scrollView.bounces = true
        webView.scrollView.alwaysBounceVertical = true
        
        view.addSubview(webView)
        
        setupRefreshControl()
    }

    

    //MARK: Setup Refresh Control
    private func setupRefreshControl() {
        webView.scrollView.bounces = true
        refreshControl = UIRefreshControl() // Assign to the instance variable
        refreshControl.addTarget(self, action: #selector(refreshWebView), for: UIControl.Event.valueChanged)
        webView.scrollView.addSubview(refreshControl)
    }

    @objc func refreshWebView(sender: UIRefreshControl) {
        webView.reload()
        sender.endRefreshing()
    }

    func load(url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func addContentRules(with rules: [WKContentRuleList]) async throws {
        for rule in rules {
            webView.configuration.userContentController.add(rule)
        }
    }
    
    func removeContentRules() async throws {
        webView.configuration.userContentController.removeAllContentRuleLists()
    }
}






// MARK: - WKNavigationDelegate
extension ContentBlockingWebViewController {
 
    // Decide Policy For
    // Check if a link has been interacted by the user and if the core domain is the same. If yes then open in the internal browser, otherwise in the external browser.
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url,
              let host = url.host else {
            decisionHandler(.allow)
            return
        }
        
        // If it's not a user-initiated link click, allow internal navigation
        if navigationAction.navigationType != .linkActivated {
            decisionHandler(.allow)
            return
        }
        
        guard let currentHost = webView.url?.host else {
            decisionHandler(.allow)
            return
        }
        
        // Compare domain cores for user-initiated navigation
        let currentMainDomain = getDomainCore(currentHost)
        let targetMainDomain = getDomainCore(host)
        
        if currentMainDomain == targetMainDomain {
            // Allowing internal navigation to same domain
            decisionHandler(.allow)
        } else {
            //Opening external browser for navigation to different domain
            decisionHandler(.cancel)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let externalWebVC = ExternalWebViewController(url: url, modelContext: self.modelContext)
                externalWebVC.modalPresentationStyle = .fullScreen
                self.present(externalWebVC, animated: true)
            }
        }
    }
    
    // New Web View called "_blank" and similar
    // Check if a link has been interacted by the user and if the core domain is the same. If yes then open in the internal browser, otherwise in the external browser.
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url,
              let host = url.host else {
            // No host found in request
            return nil
        }
        
        guard let currentHost = webView.url?.host else {
            // Loading new window request in current webview
            webView.load(navigationAction.request)
            return nil
        }
        
        // Treat new window requests as user-initiated and compare domain cores
        let currentMainDomain = getDomainCore(currentHost)
        let targetMainDomain = getDomainCore(host)
        
        if currentMainDomain == targetMainDomain {
            // Loading in current webview same domain
            webView.load(navigationAction.request)
        } else {
            // Opening external browser for new window request, different domain
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let externalWebVC = ExternalWebViewController(url: url, modelContext: self.modelContext)
                externalWebVC.modalPresentationStyle = .fullScreen
                self.present(externalWebVC, animated: true)
            }
        }
        return nil
    }

    private func getDomainCore(_ host: String) -> String {
        let components = host.lowercased().split(separator: ".")
        guard components.count >= 2 else { return host.lowercased() }
        let mainDomain = components.suffix(2).joined(separator: ".")
        return mainDomain
    }
    
   
}




