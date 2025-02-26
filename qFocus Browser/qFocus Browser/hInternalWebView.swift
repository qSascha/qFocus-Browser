//
//  hInternalWebView.swift
//  qFocus Browser
//
//  Created by qSascha on 2025-02-01.
//

@preconcurrency import WebKit
import UIKit
import SwiftUI
import SwiftData





//MARK: View: WebViews
struct WebViews: View {
    @Query(
        filter: #Predicate<sitesStorage> { $0.siteName != ""},
        sort: \sitesStorage.siteOrder
    ) var webSites: [sitesStorage]
    @Query() var settingsDataArray: [settingsStorage]

    @EnvironmentObject private var startViewModel: StartViewModel
    @EnvironmentObject var globals: GlobalVariables

    
    
    var body: some View {
        @Bindable var settingsData = settingsDataArray[0]

        VStack {
            if (settingsData.showNavBar) {
                Rectangle()
                    .opacity(0)
                    .frame(width: 30, height: 30, alignment: .center)
            }
            
            ZStack {
                ForEach(0..<webSites.count, id: \.self) { index in
                    WebViewContainer(webViewController: startViewModel.getWebViewController(index))
                        .zIndex(globals.currentTab == index ? 1 : 0)
                        .onAppear {
                            Task {
                                await startViewModel.updateWebView(index: index, site: webSites[index])
                            }
                        }
                        .onChange(of: webSites[index].siteURL) { _, _ in
                            startViewModel.resetInitialLoadState(for: index)
                            Task {
                                await startViewModel.updateWebView(index: index, site: webSites[index])
                            }
                        }
                        .onChange(of: webSites[index].enableJSBlocker) { _, _ in
                            Task {
                                await startViewModel.updateWebView(index: index, site: webSites[index])
                            }
                        }
                }

            }
        }
    }
}

struct WebViewContainer: UIViewControllerRepresentable {
    let webViewController: WebViewController
    
    func makeUIViewController(context: Context) -> WebViewController {
        return webViewController
    }
    
    func updateUIViewController(_ uiViewController: WebViewController, context: Context) {
        // Update the view controller if needed
    }
}







//MARK: CLASS Web View Controller
class WebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, UIAdaptivePresentationControllerDelegate {

    var webView: WKWebView!
    private var refreshControl: UIRefreshControl!
    private var hasSetupWebView = false
    private var initialRequestDesktop: Bool = false
    private var currentRequestDesktop: Bool = false

    private var isHandlingExternalNavigation = false
    private var lastNavigationTime: Date?
    private let navigationCooldown: TimeInterval = 0.5


    init(requestDesktop: Bool = false) {
        self.initialRequestDesktop = requestDesktop
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func loadView() {
        super.loadView()
        if !hasSetupWebView {
            setupWebView(requestDesktop: initialRequestDesktop)
            setupRefreshControl()
            hasSetupWebView = true
        }
    }

    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set both delegates for the webView
        webView.navigationDelegate = self
        webView.uiDelegate = self
    }
    
    

    //MARK: Update Web View Conf
    func updateWebViewConfiguration(requestDesktop: Bool) {
        // Store the new state
        self.currentRequestDesktop = requestDesktop
        
        // Create new configuration
        let config = WKWebViewConfiguration()
        let prefs = WKWebpagePreferences()
        prefs.preferredContentMode = requestDesktop ? .desktop : .mobile
        config.defaultWebpagePreferences = prefs
        
        // Apply user agent
        let userAgent = requestDesktop ?
            "Mozilla/5.0 (Macintosh; Apple Silicon Mac OS X 14_3_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2.1 Safari/605.1.15" :
            nil
        
        // Ensure we're on the main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Update user agent
            self.webView.customUserAgent = userAgent
            
            // Update configuration
            self.webView.configuration.defaultWebpagePreferences = prefs
            
            // Force reload from scratch
            if let url = self.webView.url {
                self.webView.load(URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData))
            } else {
                self.webView.reload()
            }
        }
    }

    
    

    //MARK: Setup Web View
//    func setupWebView() {
    func setupWebView(requestDesktop: Bool) {
        // Store initial state
        self.currentRequestDesktop = requestDesktop


        let configuration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        configuration.userContentController = contentController
        
        // Desktop or mobile site request
        let webpagePreferences = WKWebpagePreferences()
        webpagePreferences.preferredContentMode = requestDesktop ? .desktop : .mobile
        configuration.defaultWebpagePreferences = webpagePreferences


        let processPool = WKProcessPool()
        configuration.processPool = processPool
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        
        webView = WKWebView(frame: view.bounds, configuration: configuration)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true

        // For desktop sites only
        if requestDesktop {
            webView.customUserAgent = "Mozilla/5.0 (Macintosh; Apple Silicon Mac OS X 14_3_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2.1 Safari/605.1.15"
        }

        // Setup scroll view properties
        webView.scrollView.bounces = true
        webView.scrollView.alwaysBounceVertical = true
        
        view.addSubview(webView)
        
        setupRefreshControl()
    }


    func forceRefreshConfiguration() {
        updateWebViewConfiguration(requestDesktop: currentRequestDesktop)
    }


    //MARK: Setup Refresh Control
    private func setupRefreshControl() {
        webView.scrollView.bounces = true
        refreshControl = UIRefreshControl()
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
 



    // MARK: Decide Policy For
    // Check if a link has been interacted by the user and if the core domain is the same. If yes then open in the internal browser, otherwise in the external browser.
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
         // Check if we're in the cooldown period after dismissal
         if let lastNav = lastNavigationTime,
            Date().timeIntervalSince(lastNav) < navigationCooldown {
             decisionHandler(.cancel)
             return
         }

         // If we're handling external navigation, prevent any other navigation
         if isHandlingExternalNavigation {
             decisionHandler(.cancel)
             return
         }

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
         
         let currentMainDomain = getDomainCore(currentHost)
         let targetMainDomain = getDomainCore(host)
         
         if currentMainDomain == targetMainDomain {
             decisionHandler(.allow)
         } else {
             decisionHandler(.cancel)
             
             isHandlingExternalNavigation = true
             
             DispatchQueue.main.async { [weak self] in
                 guard let self = self else { return }
                 let externalViewController = ExternalWebViewUIK(url: url)
                 externalViewController.delegate = self
                 let navigationController = UINavigationController(rootViewController: externalViewController)
                 navigationController.modalPresentationStyle = .fullScreen
                 self.present(navigationController, animated: true)
             }
         }
     }

    
    
    
    
    // MARK: "_blank" and similar
    // called "_blank" and similar
    // Check if a link has been interacted by the user and if the core domain is the same. If yes then open in the internal browser, otherwise in the external browser.
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
         if isHandlingExternalNavigation {
             return nil
         }

         guard let url = navigationAction.request.url,
               let host = url.host else {
             return nil
         }
         
         guard let currentHost = webView.url?.host else {
             webView.load(navigationAction.request)
             return nil
         }
         
         let currentMainDomain = getDomainCore(currentHost)
         let targetMainDomain = getDomainCore(host)
         
         if currentMainDomain == targetMainDomain {
             webView.load(navigationAction.request)
         } else {
             isHandlingExternalNavigation = true
             
             DispatchQueue.main.async { [weak self] in
                 guard let self = self else { return }
                 let externalViewController = ExternalWebViewUIK(url: url)
                 externalViewController.delegate = self
                 let navigationController = UINavigationController(rootViewController: externalViewController)
                 navigationController.modalPresentationStyle = .fullScreen
                 self.present(navigationController, animated: true)
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



// Add protocol for ExternalWebViewUIK delegate
protocol ExternalWebViewUIKDelegate: AnyObject {
    func externalWebViewWillDismiss()
    func externalWebViewDidDismiss()
}

// Add extension to WebViewController to implement the delegate
extension WebViewController: ExternalWebViewUIKDelegate {
    func externalWebViewWillDismiss() {
        isHandlingExternalNavigation = true
        lastNavigationTime = Date()
    }
    
    func externalWebViewDidDismiss() {
        DispatchQueue.main.asyncAfter(deadline: .now() + navigationCooldown) { [weak self] in
            self?.isHandlingExternalNavigation = false
        }
    }
}

