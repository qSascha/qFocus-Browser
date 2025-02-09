//
//  hContentViewModel.swift
//  qFocus Browser
//
//  Created by Sascha on 2025-01-25.
//
import SwiftUI
import WebKit

// MARK: Content View Model
@MainActor
class ContentViewModel: ObservableObject {

    @Published private(set) var webViewControllers: [ContentBlockingWebViewController] = []
    @Published var showAdBlockLoadStatus: Bool = false
    @Published var loadedRuleLists: Int = 0
    @Published var totalRuleLists: Int = 0
    @Published var currentURL: String?

    let scriptManager: ScriptManager
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

    

    //MARK: Update Web View
    func updateWebView(at index: Int, with urlString: String) async {
        guard index < webViewControllers.count,
              !urlString.isEmpty,
              let url = URL(string: urlString) else {
                  return
              }
        
        if hasInitiallyLoaded[index] != true {
            let webViewController = webViewControllers[index]
            
            // Load site-specific scripts
            scriptManager.loadScripts(for: url, webViewController: webViewController)

            // Load the URL
            webViewController.load(url: url)
            hasInitiallyLoaded[index] = true
        }
        
        currentURL = urlString
        objectWillChange.send()
    }




    //MARK: Helper Functions
    func resetInitialLoadState(for index: Int) {
        hasInitiallyLoaded[index] = false
    }

    @objc private func handleURLUpdate(_ notification: Notification) {
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



