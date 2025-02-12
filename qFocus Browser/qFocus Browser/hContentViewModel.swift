//
//  hContentViewModel.swift
//  qFocus Browser
//
//  Created by Sascha on 2025-01-25.
//
import SwiftUI
import SwiftData
import WebKit


// MARK: Content View Model
@MainActor
class ContentViewModel: ObservableObject {
    @Published private(set) var webViewControllers: [ContentBlockingWebViewController] = []
    @Published var showAdBlockLoadStatus: Bool = false
    @Published var loadedRuleLists: Int = 0
    @Published var totalRuleLists: Int = 0

    let scriptManager: ScriptManager
    private var activeRuleIdentifiers: Set<String> = []
    private var currentCompiledRules: [WKContentRuleList] = []
    private var hasInitiallyLoaded: [Int: Bool] = [:]
    private var hasInitializedRules = false
    private let blockListManager = BlockListManager()
    

    
    
    init() {
        self.scriptManager = ScriptManager()

        // Initialize with default settings
        self.webViewControllers = (0...5).map { index in
            let controller = ContentBlockingWebViewController(requestDesktop: false)
            controller.loadView()
            return controller
        }
    }


    // Update controllers with site data
    func updateWebViewControllers(with sites: [sitesStorage]) async {
        
        for index in 0..<webViewControllers.count {
            if index < sites.count {
                let site = sites[index]
                
                // Ensure we're on the main thread and force the update
                await MainActor.run {
                    self.webViewControllers[index].updateWebViewConfiguration(requestDesktop: site.requestDesktop)
                    
                    // Add a slight delay and force a refresh
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.webViewControllers[index].forceRefreshConfiguration()
                    }
                }
            }
        }
    }



    
    
    //MARK: Should Update Filter
    func shouldUpdateFilters(lastUpdate: Date?) -> Bool {
        guard let lastUpdate = lastUpdate else {
            return true
        }
        
        let sevenDays: TimeInterval = 7 * 24 * 60 * 60 // 7 days in seconds
        return Date().timeIntervalSince(lastUpdate) >= sevenDays
    }


    

    //MARK: Update Web View
    func updateWebView(index: Int, site: sitesStorage) async {
        guard index < webViewControllers.count else { return }
  
        guard index < webViewControllers.count,
              !site.siteURL.isEmpty,
              let url = URL(string: site.siteURL) else {
                  return
              }

        let webViewController = webViewControllers[index]
        
        // Clear existing scripts
        webViewController.webView.configuration.userContentController.removeAllUserScripts()
        
        // Load new scripts if enabled
        if site.enableJSBlocker {
            scriptManager.loadScripts(for: url, webViewController: webViewController)
        }

        if hasInitiallyLoaded[index] != true {
            // Initial page load
            webViewController.load(url: url)
            hasInitiallyLoaded[index] = true
        } else {
            // Reload the current page to apply changes
            webViewController.webView.reload()
        }

        objectWillChange.send()
    }



    //MARK: Helper Functions
    func resetInitialLoadState(for index: Int) {
        hasInitiallyLoaded[index] = false
    }


    @objc private func handleUpdateRequest(_ notification: Notification) {
        // Force view update
        objectWillChange.send()
    }
    

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    

    func getWebViewController(_ index: Int) -> ContentBlockingWebViewController {
        guard index < webViewControllers.count else {
            print("ERROR: Requested web view controller index \(index) out of bounds")
            return ContentBlockingWebViewController()
        }
        return webViewControllers[index]
    }

    
    func updateDesktopMode(for index: Int, requestDesktop: Bool) {
        guard index < webViewControllers.count else { return }
        webViewControllers[index].updateWebViewConfiguration(requestDesktop: requestDesktop)
    }





    //MARK: Initialize Blocker
    @MainActor
    func initializeBlocker(settings: settingsStorage, enabledFilters: [adBlockFilters], modelContext: ModelContext, forceUpdate: Bool = false) async throws {
        guard !hasInitializedRules else {
            return
        }

        guard settings.enableAdBlock else {
            return
        }

        // Check if update is needed
        if forceUpdate || shouldUpdateFilters(lastUpdate: settings.adBlockLastUpdate) {
            showAdBlockLoadStatus = true
            defer { showAdBlockLoadStatus = false }

            totalRuleLists = enabledFilters.count
            loadedRuleLists = 0
            
            for filter in enabledFilters {
                guard let url = URL(string: filter.urlString) else {
                    continue
                }

                do {
                    // Pass the filter's identName as the identifier
                    let result = try await blockListManager.processURL(url, identifier: filter.identName)
                    
                    for webViewController in webViewControllers {
                        try await webViewController.addContentRules(with: result.compiled)
                    }
                    
                    loadedRuleLists += 1
                } catch {
                    print("Error processing block list: \(filter.identName): \(error.localizedDescription)")
                }
            }
            settings.adBlockLastUpdate = Date()
            try modelContext.save() // Explicitly save the changes

            showAdBlockLoadStatus = false
        }
    }




    //MARK: Toggle Blocking
    @MainActor
    func toggleBlocking(isEnabled: Bool, enabledFilters: [adBlockFilters]) async {

        if isEnabled {
            totalRuleLists = enabledFilters.count
            loadedRuleLists = 0

            for filter in enabledFilters {
                guard let url = URL(string: filter.urlString) else {
                    print("Invalid URL for filter: \(filter.identName)")
                    loadedRuleLists += 1
                    continue
                }
                
                do {
                    let result = try await blockListManager.processURL(url, identifier: filter.identName)
                    currentCompiledRules.append(contentsOf: result.compiled)
                    
                    for webViewController in webViewControllers {
                        try await webViewController.addContentRules(with: result.compiled)
                    }
                    loadedRuleLists += 1
                } catch {
                    print("Error processing block list \(filter.identName): \(error.localizedDescription)")
                    loadedRuleLists += 1
                }
            }
        } else {

            currentCompiledRules = []
            loadedRuleLists = 0
            totalRuleLists = 0
            
            do {
                for webViewController in webViewControllers {
                    try await webViewController.removeContentRules()
                }
            } catch {
                print("Error removing content rules: \(error.localizedDescription)")
            }

        }

    }
}



