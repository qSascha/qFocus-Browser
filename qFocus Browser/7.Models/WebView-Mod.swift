//
//  WebViewItem-Mod.swift
//  qFocus Browser
//
//
import Foundation
import WebKit



struct WebViewModel: Identifiable {
    let id: UUID
    var settings: SitesStorage
    
    // Runtime-only (in-memory) state
    var url: URL
    var isLoading: Bool = false
    var estimatedProgress: Double = 0.0
    var canGoBack: Bool = false
    var canGoForward: Bool = false
    var contentRuleList: WKContentRuleList?
    var userScripts: [WKUserScript] = []
}
