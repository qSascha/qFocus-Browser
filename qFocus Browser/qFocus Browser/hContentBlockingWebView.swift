//
//  ContentBlockingWebViewController.swift
//  qFocus Browser
//
//  Created by qSascha on 2025-02-01.
//

import WebKit
import UIKit
import SwiftUI




class ContentBlockingWebViewController: UIViewController {

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

        view.addSubview(webView)
    }
    
    private func setupRefreshControl() {
        webView.scrollView.bounces = true
        let refreshControl = UIRefreshControl()
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
extension ContentBlockingWebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url,
              let host = url.host else {
            decisionHandler(.allow)
            return
        }
        
        if let currentHost = webView.url?.host,
           host != currentHost,
           navigationAction.navigationType == .linkActivated {
            decisionHandler(.cancel)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let externalWebVC = ExternalWebViewController(url: url, modelContext: self.modelContext)
                externalWebVC.modalPresentationStyle = .fullScreen
                self.present(externalWebVC, animated: true)
            }
            return
        }
        decisionHandler(.allow)
    }
}

// MARK: - WKUIDelegate
extension ContentBlockingWebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url {
            let externalWebVC = ExternalWebViewController(url: url, modelContext: self.modelContext)
            externalWebVC.modalPresentationStyle = .fullScreen
            present(externalWebVC, animated: true)
        }
        return nil
    }
}
