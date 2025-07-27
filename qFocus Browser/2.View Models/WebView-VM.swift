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
    private let minUpTriggerDistance: CGFloat = 3
    private let minDownTriggerDistance: CGFloat = 8
    
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
        if settingsRepo.get().adBlockUpdateFrequency != 0 && site.enableAdBlocker {
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
//        config.processPool = WKProcessPool()
        
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

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        currentURL = webView.url
        print("----- Updated currentURL: \(String(describing: currentURL))")
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
            decisionHandler(.allow, preferences)
/*
            decisionHandler(.cancel, preferences)
            print("URL: \(url)")
            var request = URLRequest(url: url)
            webView.load(request)
*/
            return

        } else {
            
            // Different domain, opening in external browser
            decisionHandler(.cancel, preferences)
            CombineRepo.shared.triggerExternalBrowser.send(url)
        }
    }




    
    
    
    


    /// Handles requests to create a new web view (e.g., for popups).
    /// Instead of creating a new window, this method either loads the URL in the current web view
    /// if it's in the same domain, or presents it in an external view if it's from a different domain.
    /// This approach maintains the focus-oriented browsing experience.
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
            CombineRepo.shared.triggerExternalBrowser.send(url)

        }
        return nil
    }
    
    /// Extracts the core domain from a hostname.
    /// Takes a hostname string and returns the main domain (e.g., "example.com" from "www.example.com").
    /// This is used for domain comparison when enforcing navigation restrictions.
    private func getDomainCore(_ host: String) -> String {
        let components = host.lowercased().split(separator: ".")
        guard components.count >= 2 else { return host.lowercased() }
        let mainDomain = components.suffix(2).joined(separator: ".")
        return mainDomain
    }





}



//MARK: UI Scroll View Delegate
extension WebViewVM: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffsetY = scrollView.contentOffset.y
        let deltaY = currentOffsetY - lastContentOffsetY
        accumulatedScrollDistance += deltaY
        let now = Date()

        if accumulatedScrollDistance < 0 {
            // Scrolling down
            if abs(accumulatedScrollDistance) >= minDownTriggerDistance {
                CombineRepo.shared.updateNavigationBar.send(false)
                lastScrollTriggerTime = now
                accumulatedScrollDistance = 0
            }
        } else if accumulatedScrollDistance > 0 {
            // Scrolling up
            if abs(accumulatedScrollDistance) >= minUpTriggerDistance {
                CombineRepo.shared.updateNavigationBar.send(true)
                lastScrollTriggerTime = now
                accumulatedScrollDistance = 0
            }
        }
        accumulatedScrollDistance = 0
        lastContentOffsetY = currentOffsetY
    }
}

