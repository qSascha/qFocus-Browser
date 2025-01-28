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

    private let blockListManager = BlockListManager()
    @Published private(set) var webViewControllers: [ContentBlockingWebViewController] = []
    @Published var loadedRuleLists: Int = 0
    @Published var totalRuleLists: Int = 0
    private var currentCompiledRules: [WKContentRuleList] = []
    
    private let blockListURLs: [URL] = [
        "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_2_Base/filter.txt",
        "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_3_Spyware/filter.txt",
        "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_4_Social/filter.txt",
        "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_11_Mobile/filter.txt",
        "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_14_Annoyances/filter.txt",
        "https://filters.adtidy.org/extension/chromium-mv3/filters/24.txt"
    ].compactMap { URL(string: $0) }
    
    init() {
        // Initialize all web view controllers
        webViewControllers = (0...4).map { _ in
            let controller = ContentBlockingWebViewController()
            controller.loadView()
            controller.setupWebView()
            controller.setupRefreshControl()
            controller.loadAndInjectScript()
            return controller
        }
    }
    
    func getWebViewController(_ index: Int) -> ContentBlockingWebViewController {
        guard index < webViewControllers.count else {
            print("ERROR: Requested web view controller index \(index) out of bounds")
            return ContentBlockingWebViewController()
        }
        return webViewControllers[index]
    }

    @MainActor
    func initializeBlocker(isEnabled: Bool) async {
        
        totalRuleLists = blockListURLs.count
        loadedRuleLists = 0
        
        for (index, url) in blockListURLs.enumerated() {
            do {
                let result = try await blockListManager.processURL(url)
                
                if let compiledRules = result.compiled {
                    // Apply rules to all web views
                    for webViewController in webViewControllers {
                        try await webViewController.addContentRules(with: [compiledRules])
                    }
                    print("BlockListManager: Successfully applied rules from \(url.lastPathComponent) to \(webViewControllers.count) WebViews")
                }
            } catch {
                print("BlockListManager: Error processing block list: \(url): \(error.localizedDescription)")
            }
            loadedRuleLists += 1
        }
        
        print("BlockListManager: Successfully processed \(loadedRuleLists)/\(totalRuleLists) lists")
    }
    
    @MainActor
    func toggleBlocking(isEnabled: Bool) async {
        
        if isEnabled {
            // Initialize the blocker if it's being enabled
            totalRuleLists = blockListURLs.count
            loadedRuleLists = 0
            
            for (_, url) in blockListURLs.enumerated() {
                do {
                    let result = try await blockListManager.processURL(url)
                    if let compiledRules = result.compiled {
                        currentCompiledRules.append(compiledRules)
                        // Apply rules to all web views
                        for webViewController in webViewControllers {
                            try await webViewController.addContentRules(with: [compiledRules])
                        }
                    }
                    loadedRuleLists += 1
                } catch {
                    print("Error processing block list \(url): \(error.localizedDescription)")
                    loadedRuleLists += 1
                }
            }
            print("Finished loading ad blocking rules")
        } else {
            // Clear all rules if it's being disabled
            currentCompiledRules = []
            loadedRuleLists = 0
            totalRuleLists = 0
            
            do {
                // Remove rules from all web views
                for webViewController in webViewControllers {
//                    try await webViewController.setupContentRules(with: [])
                    try await webViewController.removeContentRules()
                }
                print("Successfully removed all content rules")
            } catch {
                print("Error removing content rules: \(error.localizedDescription)")
            }
        }
    }
}



