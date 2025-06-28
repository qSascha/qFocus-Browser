//
//  WebView-VM.swift
//  qFocus Browser
//
//
import Foundation
import WebKit
import Combine



@MainActor
final class WebViewVM: NSObject, ObservableObject {
    @Published var isLoading: Bool = false
    @Published var estimatedProgress: Double = 0.0
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var currentURL: URL?
    private var lastNavigationTime: Date?
    private var initialHost: String?

    private var isHandlingExternalNavigation = false

    var webView: WKWebView
    private let id: UUID = UUID()
    
    private let adBlockRepo : AdBlockFilterRepo
    private let settingsRepo: SettingsRepo
    private let sitesRepo: SitesRepo
    private let greasyScriptUC: GreasyScriptUC
    private var lastContentOffsetY: CGFloat = 0

    private var lastScrollTriggerTime: Date = .distantPast
    private var accumulatedScrollDistance: CGFloat = 0
    private let minTriggerInterval: TimeInterval = 0.4
    private let minTriggerDistance: CGFloat = 60

    var webViewID: UUID = UUID()
    
    
    
    
    

    //MARK: Init
    init(adBlockRepo:AdBlockFilterRepo, settingsRepo: SettingsRepo, sitesRepo: SitesRepo, greasyScriptUC: GreasyScriptUC) {
        self.adBlockRepo = adBlockRepo
        self.settingsRepo = settingsRepo
        self.sitesRepo = sitesRepo
        self.greasyScriptUC = greasyScriptUC
        
        self.webView = WKWebView()
        
    }



    //MARK: Initialize WebView
    func initializeWebView(assignViewID: UUID) async {
        
        self.webViewID = assignViewID
        
        guard let site = sitesRepo.getAllSites().first(where: { $0.cookieStoreID == assignViewID }) else {
#if DEBUG
            print("❌ Could not find site with ID \(assignViewID)")
#endif
            return
        }
        
#if DEBUG
        print("✅ Initializing WebView for site \(site.siteName)")
        print("URL: \(site.siteURL)")
        print("CookieStore: \(site.cookieStoreID)")
        print("Request Desktop: \(site.requestDesktop)")
        print("Enable Greasy: \(site.enableGreasy)")
        print("Enable AdBlocker: \(site.enableAdBlocker)")
        print("-------------------------------------------------")
#endif
        
        guard let url = URL(string: site.siteURL) else {
#if DEBUG
            print("❌ Invalid URL string: \(site.siteURL)")
#endif
            return
        }

        let config = WKWebViewConfiguration()

        // Cookie Store ID
        config.websiteDataStore = WKWebsiteDataStore(forIdentifier: site.cookieStoreID)

        
        // Request Desktop 1/2
        let prefs = WKWebpagePreferences()
        prefs.preferredContentMode = site.requestDesktop ? .desktop : .mobile
        config.defaultWebpagePreferences = prefs
        
        
        let userContentController = WKUserContentController()

        // Enable AdBlocking
        if settingsRepo.get().enableAdBlock && site.enableAdBlocker {
            for setting in adBlockRepo.getAllEnabled() {
                do {
                    if let ruleList = try await WKContentRuleListStore.default().contentRuleList(forIdentifier: setting.filterID) {
                        userContentController.add(ruleList)
                }
                } catch {
#if DEBUG
                    print("⚠️ AdBlock rule load failed: \(error.localizedDescription)")
#endif
                }
            }
            
        }

        if site.enableGreasy {
            greasyScriptUC.loadScripts(for: url)
            for script in greasyScriptUC.getUserScripts(for: url) {
                userContentController.addUserScript(script)
            }
        }
        
        config.userContentController = userContentController
        config.processPool = WKProcessPool()
        
        // Build WKWebView with full configuration AFTER all rules are loaded
        let newWebView = WKWebView(frame: .zero, configuration: config)

        newWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        newWebView.allowsBackForwardNavigationGestures = true
        newWebView.scrollView.bounces = true
        newWebView.scrollView.alwaysBounceVertical = true
        newWebView.customUserAgent = site.requestDesktop
        ? "Mozilla/5.0 (Macintosh; Apple Silicon Mac OS X 14_3_1) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.2.1 Safari/605.1.15"
        : nil
        
        self.webView = newWebView
        webView.scrollView.delegate = self

        /// Navigation Delegate to  inspect for external URL
        webView.navigationDelegate = self
        print("🧭 navigationDelegate for \(site.siteName) set to: \(ObjectIdentifier(self))")

        webView.load(URLRequest(url: url))

/*
        // Workaround
        /// Sometimes websites won't load the Desktop version, even so it is enabled in the settings.
        /// Programaticaly reloading the site after a short while helps.
        ///

        if site.requestDesktop {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                webView.reload()
            }
        }
*/
    }
    
    

    //MARK: Get WebView
    func getWebView() -> WKWebView {
        return webView
    }
    
    
    
    //MARK: Load
    func load(url: URL) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    
    
    //MARK: Reload
    func reload() {
        webView.reload()
    }
    
    
    
    //MARK: Go Back
    func goBack() {
        if webView.canGoBack {
            webView.goBack()
        }
    }
    
    
    
    // Go Forwdard
    func goForward() {
        if webView.canGoForward {
            webView.goForward()
        }
    }
    
    
    
    // Apply Desktop Request
    func applyDesktopRequest(_ enabled: Bool) {
        if enabled {
            webView.customUserAgent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.1 Safari/605.1.15"
        } else {
            webView.customUserAgent = nil
        }
    }
    

}



//MARK: Navigation Delegate
extension WebViewVM: WKNavigationDelegate {
    

    @objc
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        preferences: WKWebpagePreferences,
        decisionHandler: @escaping @MainActor @Sendable (WKNavigationActionPolicy, WKWebpagePreferences) -> Void
    ) {

        // Save current URL for ShareSheet usagae
        currentURL = webView.url

        print("🔍 Navigation attempt to: \(navigationAction.request.url?.absoluteString ?? "nil")")
        

        // Cooldown logic to prevent repeated triggers
        if let lastNav = lastNavigationTime,
           Date().timeIntervalSince(lastNav) < 1 {
            decisionHandler(.cancel, preferences)
            return
        }

        guard let url = navigationAction.request.url,
              let host = url.host else {
            decisionHandler(.allow, preferences)
            return
        }
        print("🌐 Target host: \(host)")

        // Only intercept actual link clicks
        print("➡️ Navigation type: \(navigationAction.navigationType.rawValue)")
        if navigationAction.navigationType != .linkActivated {
            decisionHandler(.allow, preferences)
            return
        }

        guard let currentHost = webView.url?.host else {
            decisionHandler(.allow, preferences)
            return
        }
        print("🏠 Current host: \(currentHost)")

        let currentMainDomain = getDomainCore(currentHost)
        let targetMainDomain = getDomainCore(host)
        print("🔍 Comparing domains: current=\(currentMainDomain), target=\(targetMainDomain)")

        if currentMainDomain == targetMainDomain {
            decisionHandler(.allow, preferences)
            return
        } else {
            decisionHandler(.cancel, preferences)
            isHandlingExternalNavigation = true

            print("🚪 Opening external browser for: \(url.absoluteString)")
            DispatchQueue.main.async {
                CombineRepo.shared.triggerExternalBrowser.send(url)
            }
        }

    }

}



//MARK: UI Scroll View Delegate
extension WebViewVM: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffsetY = scrollView.contentOffset.y
        let deltaY = currentOffsetY - lastContentOffsetY
        accumulatedScrollDistance += deltaY
        let now = Date()
        
        if abs(accumulatedScrollDistance) >= minTriggerDistance && now.timeIntervalSince(lastScrollTriggerTime) >= minTriggerInterval {
            if accumulatedScrollDistance > 0 {
                print("Scrolling Down: \(accumulatedScrollDistance)")
                // Send Combine event for down
                CombineRepo.shared.updateNavigationBar.send(true)

            } else if accumulatedScrollDistance < 0 {
                print("Scrolling Up: \(accumulatedScrollDistance)")
                // Send Combine event for up
                CombineRepo.shared.updateNavigationBar.send(false)

            }
            lastScrollTriggerTime = now
            accumulatedScrollDistance = 0
        }
        lastContentOffsetY = currentOffsetY
    }
}
