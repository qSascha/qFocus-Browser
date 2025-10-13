//
//  WebView-VM.swift
//  qFocus Browser
//
//
import Foundation
import WebKit
import Combine
import SwiftUI
import PhotosUI
import UniformTypeIdentifiers



@MainActor
final class WebViewVM: NSObject, ObservableObject, WKUIDelegate {
    private var cancellables = Set<AnyCancellable>()

    @Published var isLoading: Bool = false
    @Published var estimatedProgress: Double = 0.0
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var currentURL: URL?
    @Published var disableEB: Bool = false
    
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
    private var pendingOpenPanelCompletion: (([URL]?) -> Void)?
    private var pickerContinuationTask: Task<Void, Never>?
    
    

    //MARK: Init
    init(adBlockRepo:AdBlockFilterRepo, settingsRepo: SettingsRepo, sitesRepo: SitesRepo, greasyScriptUC: GreasyScriptUC) {
        self.adBlockRepo = adBlockRepo
        self.settingsRepo = settingsRepo
        self.sitesRepo = sitesRepo
        self.greasyScriptUC = greasyScriptUC
        
        self.webView = WKWebView()
        
        super.init()

        // Subscribe to global external browser disabled state
        CombineRepo.shared.externalBrowserDisabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] disabled in
                self?.disableEB = disabled
            }
            .store(in: &cancellables)

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
        if settingsRepo.get().adBlockEnabled && site.enableAdBlocker {
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
        config.dataDetectorTypes = .all
        config.preferences.isFraudulentWebsiteWarningEnabled = true
//        config.ignoresViewportScaleLimits = false
        config.ignoresViewportScaleLimits = true
        config.mediaTypesRequiringUserActionForPlayback = .all
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
//        webView.scrollView.delegate = self

        /// Navigation Delegate to  inspect for external URL
        webView.navigationDelegate = self
        webView.uiDelegate = self
        print("🧭 navigationDelegate for \(site.siteName) set to: \(ObjectIdentifier(self))")

        webView.load(URLRequest(url: url))

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
        
        // Handle AppStore links
        if let url = navigationAction.request.url,
           url.host == "apps.apple.com" {
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
        print("CurrentDomain: \(currentMainDomain)")
        print("TargetDomain:  \(targetMainDomain)")

        // Allow if same main domain OR external browsing is disabled; otherwise, open externally
        if (currentMainDomain == targetMainDomain) || disableEB {
            decisionHandler(.allow, preferences)

            CombineRepo.shared.updateTopAreaColor.send()

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



//MARK: File upload support via PHPicker
extension WebViewVM {
    // Handle <input type="file"> requests from web content
    func webView(_ webView: WKWebView,
                 runOpenPanelWith parameters: WKOpenPanelParameters,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping ([URL]?) -> Void) {
        // Retain completion to call after picking
        pendingOpenPanelCompletion = completionHandler

        // Configure PHPicker based on parameters
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = parameters.allowsMultipleSelection ? 0 : 1 // 0 = unlimited
        config.filter = .any(of: [.images, .videos])

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self

        // Present from the topmost view controller
        guard let presenter = Self.topMostViewController() else {
            completionHandler(nil)
            pendingOpenPanelCompletion = nil
            return
        }
        presenter.present(picker, animated: true)
    }

    // Helper to find top-most view controller to present from
    private static func topMostViewController(base: UIViewController? = UIApplication.shared.connectedScenes
        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
        .first?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topMostViewController(base: selected)
        }
        if let presented = base?.presentedViewController {
            return topMostViewController(base: presented)
        }
        return base
    }
}



//MARK: PHPickerViewControllerDelegate
extension WebViewVM: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        // Dismiss picker
        picker.dismiss(animated: true)
        
        guard let completion = pendingOpenPanelCompletion else { return }
        
        // If user cancelled
        if results.isEmpty {
            completion(nil)
            pendingOpenPanelCompletion = nil
            return
        }
        
        // Load file representations and write to temporary URLs for WebKit
        pickerContinuationTask?.cancel()
        pickerContinuationTask = Task { @MainActor in
            var urls: [URL] = []
            
            for result in results {
                if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    if let url = await loadFileURL(from: result.itemProvider, preferredType: .image) {
                        urls.append(url)
                    }
                } else if result.itemProvider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) ||
                            result.itemProvider.hasItemConformingToTypeIdentifier(UTType.video.identifier) {
                    if let url = await loadFileURL(from: result.itemProvider, preferredType: .movie) {
                        urls.append(url)
                    }
                } else {
                    // Try any file representation
                    if let url = await loadAnyFileURL(from: result.itemProvider) {
                        urls.append(url)
                    }
                }
            }
            
            completion(urls.isEmpty ? nil : urls)
            pendingOpenPanelCompletion = nil
        }
    }
    
    // MARK: Item loading helpers
    private func loadFileURL(from provider: NSItemProvider, preferredType: UTType) async -> URL? {
        await withCheckedContinuation { continuation in
            let typeIdentifier = preferredType.identifier
            provider.loadFileRepresentation(forTypeIdentifier: typeIdentifier) { url, error in
                if let sourceURL = url {
                    // Copy to a temp location WebKit can access after provider releases the original URL
                    let destination = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension(preferredType.preferredFilenameExtension ?? "dat")
                    do {
                        if FileManager.default.fileExists(atPath: destination.path) {
                            try? FileManager.default.removeItem(at: destination)
                        }
                        try FileManager.default.copyItem(at: sourceURL, to: destination)
                        continuation.resume(returning: destination)
                    } catch {
                        continuation.resume(returning: nil)
                    }
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    private func loadAnyFileURL(from provider: NSItemProvider) async -> URL? {
        // Try image first, then movie, then any data
        if let url = await loadFileURL(from: provider, preferredType: .image) { return url }
        if let url = await loadFileURL(from: provider, preferredType: .movie) { return url }
        
        // Fallback: load data representation and write to temp
        return await withCheckedContinuation { continuation in
            if provider.hasItemConformingToTypeIdentifier(UTType.data.identifier) {
                provider.loadDataRepresentation(forTypeIdentifier: UTType.data.identifier) { data, error in
                    guard let data else {
                        continuation.resume(returning: nil)
                        return
                    }
                    let destination = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
                    do {
                        try data.write(to: destination)
                        continuation.resume(returning: destination)
                    } catch {
                        continuation.resume(returning: nil)
                    }
                }
            } else {
                continuation.resume(returning: nil)
            }
        }
    }
    
}
