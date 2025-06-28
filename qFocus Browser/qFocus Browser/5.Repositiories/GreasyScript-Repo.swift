//
//  GreasyScript-Repo.swift
//  qFocus Browser
//
//
import CoreData
import Foundation
import WebKit



// MARK: GreasyScriptUC
final class GreasyScriptRepo: ObservableObject {
    let context: NSManagedObjectContext
    
    @Published var loadedScripts: [greasyScriptItem] = []
    
    //MARK: Init
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    
    
    //MARK: Load Scripts
    func loadScripts(for site: String, webViewController: AnyObject? = nil) async {
        // Load and parse scripts for the site, update loadedScripts
        // Injection is handled externally
        let allScripts = createGreasyScriptsList()
        loadedScripts = allScripts.filter { $0.coreSite == site && $0.scriptEnabled }
    }
    


    //MARK: Get User Scripts
    func getUserScripts(for webView: WKWebView) async -> [WKUserScript] {
        await withTaskGroup(of: WKUserScript?.self) { group in
            for scriptItem in loadedScripts {
                group.addTask {
                    guard let url = URL(string: scriptItem.scriptURL),
                          let scriptSource = try? String(contentsOf: url) else {
                        return nil
                    }
                    return await MainActor.run {
                        WKUserScript(source: scriptSource, injectionTime: .atDocumentStart, forMainFrameOnly: true)
                    }
                }
            }
            var results: [WKUserScript] = []
            for await script in group {
                if let script = script {
                    results.append(script)
                }
            }
            return results

        }
    }
    
    
/*
    func getUserScripts(for webView: WKWebView) -> [WKUserScript] {
        loadedScripts.compactMap { scriptItem in
            guard let scriptSource = try? String(contentsOf: URL(string: scriptItem.scriptURL)!) else {
                return nil
            }
            return WKUserScript(source: scriptSource, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        }
    }
*/
    
}




func createGreasyScriptsList() -> [greasyScriptItem] {
    
    return [
        greasyScriptItem(
            scriptName: String(localized: "greasy.reddit.adblocker_2025-02-16.name"),
            scriptID: "reddit_adblocker_2025-02-16",
            coreSite: "reddit.com",
            scriptEnabled: true,
            scriptExplanation: String(localized: "greasy.reddit.adblocker_2025-02-16.explanation"),
            scriptLicense: "not specified",
            siteURL: "https://greasyfork.org/en/scripts/405756-reddit-promotion-blocker",
            scriptURL: "https://update.greasyfork.org/scripts/405756/Reddit%20Promotion%20Blocker.user.js"
        ),
        greasyScriptItem(
            scriptName: String(localized: "greasy.x.adblocker_2025-02-16.name"),
            scriptID: "x_adblocker_2025-02-16",
            coreSite: "x.com",
            scriptEnabled: true,
            scriptExplanation: String(localized: "greasy.x.adblocker_2025-02-16.explanation"),
            scriptLicense: "MIT",
            siteURL: "https://greasyfork.org/en/scripts/458669-remove-ads-and-promoted-tweets-on-twitter",
            scriptURL: "https://update.greasyfork.org/scripts/458669/Remove%20ads%20and%20promoted%20tweets%20on%20Twitter.user.js"
        ),
        greasyScriptItem(
            scriptName: String(localized: "greasy.youtube.agerestriction_2025-02-16.name"),
            scriptID: "youtube_agerestriction_2025-02-16",
            coreSite: "youtube.com",
            scriptEnabled: true,
            scriptExplanation: String(localized: "greasy.youtube.agerestriction_2025-02-16.explanation"),
            scriptLicense: "MIT",
            siteURL: "https://greasyfork.org/en/scripts/423851-simple-youtube-age-restriction-bypass",
            scriptURL: "https://update.greasyfork.org/scripts/423851/Simple%20YouTube%20Age%20Restriction%20Bypass.user.js"
        ),
        greasyScriptItem(
            scriptName: String(localized: "greasy.youtube.adblocker_2025-02-16.name"),
            scriptID: "youtube_adblocker_2025-02-16",
            coreSite: "youtube.com",
            scriptEnabled: true,
            scriptExplanation: String(localized: "greasy.youtube.adblocker_2025-02-16.explanation"),
            scriptLicense: "MIT",
            siteURL: "https://greasyfork.org/en/scripts/459541-youtube-adb",
            scriptURL: "https://update.greasyfork.org/scripts/459541/YouTube去广告.user.js"
        ),
        greasyScriptItem(
            scriptName: String(localized: "greasy.x.contentwarning_2025-02-16.name"),
            scriptID: "x_contentwarning_2025-02-16",
            coreSite: "x.com",
            scriptEnabled: true,
            scriptExplanation: String(localized: "greasy.x.contentwarning_2025-02-16.explanation"),
            scriptLicense: "gpl-3-0",
            siteURL: "https://greasyfork.org/en/scripts/445650-twitter-remove-content-warning",
            scriptURL: "https://update.greasyfork.org/scripts/445650/Twitter%20Remove%20Content%20Warning.user.js"
        ),
        greasyScriptItem(
            scriptName: String(localized: "greasy.instagram.adblocker_2025-02-16.name"),
            scriptID: "instagram_adblocker_2025-02-16",
            coreSite: "instagram.com",
            scriptEnabled: true,
            scriptExplanation: String(localized: "greasy.instagram.adblocker_2025-02-16.explanation"),
            scriptLicense: "MIT",
            siteURL: "https://greasyfork.org/en/scripts/510716-block-instagram-ads-and-suggested-posts",
            scriptURL: "https://update.greasyfork.org/scripts/510716/Block%20Instagram%20Ads%20and%20Suggested%20Posts.user.js"
        ),
        greasyScriptItem(
            scriptName: String(localized: "greasy.linkedin.adblocker_2025-02-16.name"),
            scriptID: "linkedin_adblocker_2025-02-16",
            coreSite: "linkedin.com",
            scriptEnabled: true,
            scriptExplanation: String(localized: "greasy.linkedin.adblocker_2025-02-16.explanation"),
            scriptLicense: "n/a",
            siteURL: "https://greasyfork.org/en/scripts/386859-linkedinnopromoted",
            scriptURL: "https://update.greasyfork.org/scripts/386859/LinkedInNoPromoted.user.js"
        ),
        greasyScriptItem(
            scriptName: String(localized: "greasy.duolingo.adblocker_2025-02-16.name"),
            scriptID: "duolingo_adblocker_2025-02-16",
            coreSite: "duolingo.com",
            scriptEnabled: true,
            scriptExplanation: String(localized: "greasy.duolingo.adblocker_2025-02-16.explanation"),
            scriptLicense: "n/a",
            siteURL: "https://greasyfork.org/en/scripts/501941-super-duolingo-ad-blocker",
            scriptURL: "https://update.greasyfork.org/scripts/501941/Super%20Duolingo%20Ad%20Blocker.user.js"
        )
        // ***************************************************************************************************************
/*
        greasyScriptItem(
            scriptName: String(localized: "greasy."),
            scriptID: "__2025-xx-yy",
            coreSite: "",
            scriptEnabled: String(localized: "greasy."),
            scriptExplanation: "",
            scriptLicense: "",
            siteURL: "",
            scriptURL: ""
        ),
 */

    ]
}
