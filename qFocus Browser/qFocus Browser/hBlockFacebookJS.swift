//
//  hBlockFacebookJS.swift
//  qFocus Browser
//
//  Created by Sascha on 2025-01-04.
//
/*

 downloadAndCacheScript(completion:): Downloads the script, converts it, and saves it to the cache directory.
 convertScript(_:): Converts the script by removing metadata and adapting GreasyMonkey-specific APIs.
 loadScript(completion:): Loads the script from the cache or downloads it if it should be updated.
 shouldUpdateScript(): Checks if the script should be updated based on the last update date.
 injectScriptIntoWebView(webView:script:): Injects the converted script into a WKWebView.
 */


import Foundation
import WebKit

//class ScriptManager {
class ScriptManager: NSObject, WKScriptMessageHandler {
    
    let scriptURL: URL
    let cacheDirectory: URL
    let cacheFileName: String
    let cacheFilePath: URL
    let lastUpdateKey = "LastScriptUpdate"
    let updateInterval: TimeInterval = 7 * 24 * 60 * 60 // 7 days
    
    var webView: WKWebView?
    
    init(scriptURL: URL) {
        self.scriptURL = scriptURL
        self.cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        self.cacheFileName = "cachedScript.js"
        self.cacheFilePath = cacheDirectory.appendingPathComponent(cacheFileName)
    }
    
    func downloadAndCacheScript(completion: @escaping (String?) -> Void) {
        
        let task = URLSession.shared.dataTask(with: scriptURL) { data, response, error in
            
            if let error = error {
                print("Network Error: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data, let script = String(data: data, encoding: .utf8) else {
                print("Failed to convert data to string")
                completion(nil)
                return
            }
            
            let convertedScript = self.convertScript(script)
            
            do {
                try convertedScript.write(to: self.cacheFilePath, atomically: true, encoding: .utf8)
                UserDefaults.standard.set(Date(), forKey: self.lastUpdateKey)
                completion(convertedScript)
            } catch {
                print("Failed to write script to cache: \(error)")
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    func convertScript(_ script: String) -> String {
        // Remove GreasyMonkey metadata block
        let scriptWithoutMetadata = script.replacingOccurrences(of: "// ==UserScript==.*// ==/UserScript==", with: "", options: .regularExpression)
        
        // Adapt GM_addStyle
        var adaptedScript = scriptWithoutMetadata.replacingOccurrences(of: "GM_addStyle", with: "addStyle")
        
        // Adapt GM_xmlhttpRequest
        adaptedScript = adaptedScript.replacingOccurrences(of: "GM_xmlhttpRequest", with: "xmlHttpRequest")
        
        // Adapt GM_getValue
        adaptedScript = adaptedScript.replacingOccurrences(of: "GM_getValue", with: "getValue")
        
        // Adapt GM_setValue
        adaptedScript = adaptedScript.replacingOccurrences(of: "GM_setValue", with: "setValue")
        
        return adaptedScript
    }
    
    func loadScript(completion: @escaping (String?) -> Void) {
        
        if shouldUpdateScript() {
/*            print("Downloading JavaScript")

            downloadAndCacheScript { script in
                if script == nil {
                    print("ERROR: Script download failed - received nil script")
                }
                completion(script)
            }
*/
        } else {
            do {
                let cachedScript = try String(contentsOf: cacheFilePath, encoding: .utf8)
                completion(cachedScript)
            } catch {
                print("Failed to read cached script: \(error). Attempting download...")
                downloadAndCacheScript { script in
                    if script == nil {
                        print("ERROR: Fallback script download failed - received nil script")
                    }
                    completion(script)
                }
            }
        }
    }
    
    func shouldUpdateScript() -> Bool {
        if let lastUpdate = UserDefaults.standard.object(forKey: lastUpdateKey) as? Date {
            let timeInterval = Date().timeIntervalSince(lastUpdate)
            return timeInterval > updateInterval
        } else {
//            print("No record of last script update found. Updating script...")
            return true
        }
    }
    
    func injectScriptIntoWebView(webView: WKWebView, script: String) {
        self.webView = webView
        let userScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: false)
        webView.configuration.userContentController.addUserScript(userScript)
        webView.configuration.userContentController.add(self, name: "jsHandler")
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            if message.name == "jsHandler" {
                if let messageBody = message.body as? String {
                    print("Received message from JavaScript: \(messageBody)")
                }
            }
        }
    
}




// Usage Example:
/*
let scriptURL = URL(string: "https://github.com/zbluebugz/facebook-clean-my-feeds/raw/main/greasyfork-release/fb-clean-my-feeds.user.js")!
let scriptManager = ScriptManager(scriptURL: scriptURL)

scriptManager.loadScript { script in
    guard let script = script else {
        print("Failed to load the script")
        return
    }
    
    DispatchQueue.main.async {
        // Assuming you have a WKWebView instance called `webView`
        let webView = WKWebView(frame: .zero)
        scriptManager.injectScriptIntoWebView(webView: webView, script: script)
        
        // Load a URL to test the injected script
        if let url = URL(string: "https://www.facebook.com") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}
*/

