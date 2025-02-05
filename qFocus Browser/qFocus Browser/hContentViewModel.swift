//
//  hContentViewModel.swift
//  qFocus Browser
//
//  Created by Sascha on 2025-01-25.
//
import SwiftUI
//import SwiftData
import WebKit






// MARK: Content View Model
@MainActor
class ContentViewModel: ObservableObject {

    @Published private(set) var webViewControllers: [ContentBlockingWebViewController] = []
    @Published var showAdBlockLoadStatus: Bool = false
    @Published var loadedRuleLists: Int = 0
    @Published var totalRuleLists: Int = 0
    @Published var currentURL: String?

    private var scriptManager: ScriptManager
    private var activeRuleIdentifiers: Set<String> = []
    private var currentCompiledRules: [WKContentRuleList] = []
    private var hasInitiallyLoaded: [Int: Bool] = [:]
    private var hasInitializedRules = false
    private let blockListManager = BlockListManager()

    


    
    init() {
        self.scriptManager = ScriptManager()

        webViewControllers = (0...5).map { _ in
            let controller = ContentBlockingWebViewController()
            controller.loadView()
            controller.setupWebView()
            return controller
        }
        
        // Initialize load state for all indices
        for i in 0...5 {
            hasInitiallyLoaded[i] = false
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleURLUpdate),
            name: NSNotification.Name("URLUpdated"),
            object: nil
        )
    }

    
    
    //MARK: Load Site Scripts
    private func loadSiteScripts(for url: URL, webViewController: ContentBlockingWebViewController, jsScript1: String?, jsScript2: String?, jsScript3: String?) async {
        var scriptsLoaded = false
        
        // Load scripts from URLs
        if let scriptUrl1 = jsScript1, !scriptUrl1.isEmpty {
            do {
                if try await scriptManager.loadScript(urlString: scriptUrl1, identifier: "script1") {
                    scriptsLoaded = true
                }
            } catch {
                print("Failed to load script1 from URL: \(scriptUrl1)")
            }
        }
        
        if let scriptUrl2 = jsScript2, !scriptUrl2.isEmpty {
            do {
                if try await scriptManager.loadScript(urlString: scriptUrl2, identifier: "script2") {
                    scriptsLoaded = true
                }
            } catch {
                print("Failed to load script2 from URL: \(scriptUrl2)")
            }
        }
        
        if let scriptUrl3 = jsScript3, !scriptUrl3.isEmpty {
            do {
                if try await scriptManager.loadScript(urlString: scriptUrl3, identifier: "script3") {
                    scriptsLoaded = true
                }
            } catch {
                print("Failed to load script3 from URL: \(scriptUrl3)")
            }
        }
        
        // Only proceed with dependency loading if at least one script was loaded
        if scriptsLoaded {
            let group = DispatchGroup()
            
            for identifier in ["script1", "script2", "script3"] {
                group.enter()
                scriptManager.loadDependencies(for: identifier) { success in
                    if !success {
                        print("Failed to load dependencies for \(identifier)")
                    }
                    group.leave()
                }
            }
            
            group.notify(queue: .main) { [weak self] in
                guard let self = self else { return }
                self.scriptManager.injectScripts(into: webViewController.webView)
            }
        }
    }
    
    
    //MARK: Update Web View
    func updateWebView(at index: Int, with urlString: String, jsScript1: String? = nil, jsScript2: String? = nil, jsScript3: String? = nil) async {
        guard index < webViewControllers.count,
              !urlString.isEmpty,
              let url = URL(string: urlString) else {
                  return
              }
        
        if hasInitiallyLoaded[index] != true {
            let webViewController = webViewControllers[index]
            
            // First load site-specific scripts
            await loadSiteScripts(for: url, webViewController: webViewController, jsScript1: jsScript1, jsScript2: jsScript2, jsScript3: jsScript3)
            
            // Then load the URL
            webViewController.load(url: url)
            hasInitiallyLoaded[index] = true
        }
        
        currentURL = urlString
        objectWillChange.send()
    }


    
    //MARK: Helper Functions
    // Add a method to reset the initial load state if needed
    func resetInitialLoadState(for index: Int) {
        hasInitiallyLoaded[index] = false
    }

    

    @objc private func handleURLUpdate(_ notification: Notification) {  // Added parameter
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
    


    //MARK: Initialize Blocker
    @MainActor
    func initializeBlocker(isEnabled: Bool, enabledFilters: [adBlockFilters]) async throws {
        guard !hasInitializedRules else {
            return
        }

        showAdBlockLoadStatus = true

        totalRuleLists = enabledFilters.count
        loadedRuleLists = 0
        
        for filter in enabledFilters {
            guard let url = URL(string: filter.urlString) else {
                print("Invalid URL for filter: \(filter.identName)")
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
        showAdBlockLoadStatus = false

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



