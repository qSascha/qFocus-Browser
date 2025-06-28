//
//  WebViewItem-UC.swift
//  qFocus Browser
//
//
/*
import WebKit



@MainActor
final class WebViewUC {
    
    let webView: WKWebView
    private let id: UUID
    private let sitesRepo: SitesRepo
    
    private var jsBlockerRuleList: WKContentRuleList?
    private var adBlockerRuleList: WKContentRuleList?
    
    var siteOrder: Int
    var siteName: String
    var siteURL: String
    var siteFavIcon: Data?
    var enableGreasy: Bool
    var enableAdBlocker: Bool
    var requestDesktop: Bool
    var cookieStoreID: UUID?
    
    
    
    //MARK: Init
    init(id: UUID, sitesRepo: SitesRepo) {
        self.id = id
        self.sitesRepo = sitesRepo
        
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        
        self.webView = WKWebView(frame: .zero, configuration: config)
        
        // Apply initial content blockers if any
        applyContentBlockers()
    }
    
    
    
    //MARK Apply Content Blockers
    private func applyContentBlockers() {
        // Load and apply JS blocker and AdBlocker content rule lists from sitesRepo
        Task {
            if let jsRules = try? await sitesRepo.loadJSBlockerRules() {
                let jsRuleList = try? await WKContentRuleListStore.default().compileContentRuleList(
                    forIdentifier: "JSBlockerRules-\(id.uuidString)",
                    encodedContentRuleList: jsRules
                )
                if let jsRuleList = jsRuleList {
                    jsBlockerRuleList = jsRuleList
                    webView.configuration.userContentController.add(jsRuleList)
                }
            }
            
            if let adRules = try? await sitesRepo.loadAdBlockerRules() {
                let adRuleList = try? await WKContentRuleListStore.default().compileContentRuleList(
                    forIdentifier: "AdBlockerRules-\(id.uuidString)",
                    encodedContentRuleList: adRules
                )
                if let adRuleList = adRuleList {
                    adBlockerRuleList = adRuleList
                    webView.configuration.userContentController.add(adRuleList)
                }
            }
        }
    }
    
    
    
    //MARK: Inject Content Rule List
    func injectContentRuleList(_ ruleList: WKContentRuleList) {
        webView.configuration.userContentController.add(ruleList)
    }
    
    
    
    //MARK: Remove Content Rule List
    func removeContentRuleList(_ ruleList: WKContentRuleList) {
        webView.configuration.userContentController.remove(ruleList)
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
*/
