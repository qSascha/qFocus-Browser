//
//  GreasyScript-Repo.swift
//  qFocus Browser
//
//
import CoreData
import Foundation
import WebKit


enum whichScripts {
    case all
    case builtin
    case custom
}



// MARK: GreasyScript Repo
final class GreasyScriptRepo: ObservableObject {
    let context: NSManagedObjectContext
    
    @Published var loadedScripts: [GreasyScriptStorage] = []
    
    //MARK: Init
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    

/*
    //MARK: Load Scripts
    func loadScripts(for site: String, webViewController: AnyObject? = nil) async {
        // Load and parse scripts for the site, update loadedScripts
        // Injection is handled externally
        let allScripts = getAllScripts()
        loadedScripts = allScripts.filter { $0.coreSite == site && $0.scriptEnabled }
    }
*/
    
    
    //MARK: Get All Scripts
    func getAllScripts(type: whichScripts = .all, order: SortOrder = .ascending) -> [GreasyScriptStorage] {
        switch type {
            case .all:
            let request: NSFetchRequest<GreasyScriptStorage> = GreasyScriptStorage.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \GreasyScriptStorage.id, ascending: order == .ascending)]
            let scripts = (try? context.fetch(request)) ?? []
            return scripts

            case .builtin:
            let request: NSFetchRequest<GreasyScriptStorage> = GreasyScriptStorage.fetchRequest()
            request.predicate = NSPredicate(format: "defaultScript == true")
            request.sortDescriptors = [NSSortDescriptor(keyPath: \GreasyScriptStorage.id, ascending: order == .ascending)]
            let scripts = (try? context.fetch(request)) ?? []
            return scripts

            case .custom:
            let request: NSFetchRequest<GreasyScriptStorage> = GreasyScriptStorage.fetchRequest()
            request.predicate = NSPredicate(format: "defaultScript == false")
            request.sortDescriptors = [NSSortDescriptor(keyPath: \GreasyScriptStorage.id, ascending: order == .ascending)]
            let scripts = (try? context.fetch(request)) ?? []
            return scripts

        }

    }



    //MARK: Get User Scripts
    func getUserScripts(for webView: WKWebView) async -> [WKUserScript] {
        await withTaskGroup(of: WKUserScript?.self) { group in
            for scriptItem in loadedScripts {
                let scriptURLString = scriptItem.scriptURL
                group.addTask {
                    guard let url = URL(string: scriptURLString),
                          let scriptSource = try? String(contentsOf: url, encoding: .utf8) else {
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
    
    
    
    //MARK Get Enabled Scripts
    func getEnabledScriptItems(for coreSite: String) -> [GreasyScriptStorage] {
        loadedScripts.filter { $0.scriptEnabled && $0.coreSite == coreSite }
    }
    
    
    
    /// Updates an existing GreasyScriptStorage with new values from a defaultGreasyScriptItem
    func editCustomScript(script: GreasyScriptStorage, scriptName: String, coreSite: String, scriptEnabled: Bool, scriptExplanation: String, siteURL: String, scriptURL: String) {
        script.scriptName = scriptName
        script.scriptID = UUID().uuidString
        script.coreSite = coreSite
        script.scriptEnabled = scriptEnabled
        script.scriptExplanation = scriptExplanation
        script.scriptLicense = ""
        script.siteURL = siteURL
        script.scriptURL = scriptURL
        script.defaultScript = false

        do {
            try context.save()
            print("✅ Script successfully updated: \(scriptName)")
        } catch {
            print("❌ Failed to update script: \(scriptName), error: \(error.localizedDescription)")
        }
    }
    
    
    
    //MARK: Update Script
    func addCustomScript(scriptName: String, coreSite: String, scriptEnabled: Bool, scriptExplanation: String, siteURL: String, scriptURL: String ) {

        let entity = NSEntityDescription.entity(forEntityName: "GreasyScriptStorage", in: context)!
        let newScript = GreasyScriptStorage(entity: entity, insertInto: context)
        newScript.id = UUID()
        newScript.scriptName = scriptName
        newScript.scriptID = newScript.id.uuidString
        newScript.coreSite = coreSite
        newScript.scriptEnabled = scriptEnabled
        newScript.scriptExplanation = scriptExplanation
        newScript.scriptLicense = ""
        newScript.siteURL = siteURL
        newScript.scriptURL = scriptURL
        newScript.defaultScript = false
        do {
            try context.save()
        } catch {
            print("Failed to save default GreasyScripts: \(error)")
        }
        
    }

    
    
    //MARK: Delete Script
    func deleteCustomScript(_ script: GreasyScriptStorage) {
        context.delete(script)
        do {
            try context.save()
#if DEBUG
            print("✅ Script successfully deleted.")
#endif
        } catch {
#if DEBUG
            print("❌ Failed to delete script.")
#endif
        }
    }

    
    
    
    //MARK: Create default GreasyScripts
    func createDefaultGreasyScripts() {
        let defaultScripts = defaultGreasyScriptsList()
        let existingScriptIDs = Set(getAllScripts().map { $0.scriptID })
        for script in defaultScripts {
            if !existingScriptIDs.contains(script.scriptID) {
                let entity = NSEntityDescription.entity(forEntityName: "GreasyScriptStorage", in: context)!
                let newScript = GreasyScriptStorage(entity: entity, insertInto: context)
                newScript.id = script.id
                newScript.scriptName = script.scriptName
                newScript.scriptID = script.scriptID
                newScript.coreSite = script.coreSite
                newScript.scriptEnabled = script.scriptEnabled
                newScript.scriptExplanation = script.scriptExplanation
                newScript.scriptLicense = script.scriptLicense
                newScript.siteURL = script.siteURL
                newScript.scriptURL = script.scriptURL
                newScript.defaultScript = script.defaultScript
            }
        }
        do {
            try context.save()
        } catch {
            print("Failed to save default GreasyScripts: \(error)")
        }
    }

}




func defaultGreasyScriptsList() -> [defaultGreasyScriptItem] {
    
    return [
        defaultGreasyScriptItem(
            scriptName: String(localized: "greasy.reddit.adblocker_2025-02-16.name"),
            scriptID: "reddit_adblocker_2025-02-16",
            coreSite: "reddit.com",
            scriptEnabled: true,
            scriptExplanation: String(localized: "greasy.reddit.adblocker_2025-02-16.explanation"),
            scriptLicense: "not specified",
            siteURL: "https://greasyfork.org/en/scripts/405756-reddit-promotion-blocker",
            scriptURL: "https://update.greasyfork.org/scripts/405756/Reddit%20Promotion%20Blocker.user.js",
            defaultScript: true
        ),
        defaultGreasyScriptItem(
            scriptName: String(localized: "greasy.x.adblocker_2025-02-16.name"),
            scriptID: "x_adblocker_2025-02-16",
            coreSite: "x.com",
            scriptEnabled: true,
            scriptExplanation: String(localized: "greasy.x.adblocker_2025-02-16.explanation"),
            scriptLicense: "MIT",
            siteURL: "https://greasyfork.org/en/scripts/458669-remove-ads-and-promoted-tweets-on-twitter",
            scriptURL: "https://update.greasyfork.org/scripts/458669/Remove%20ads%20and%20promoted%20tweets%20on%20Twitter.user.js",
            defaultScript: true
        ),
        defaultGreasyScriptItem(
            scriptName: String(localized: "greasy.youtube.agerestriction_2025-02-16.name"),
            scriptID: "youtube_agerestriction_2025-02-16",
            coreSite: "youtube.com",
            scriptEnabled: true,
            scriptExplanation: String(localized: "greasy.youtube.agerestriction_2025-02-16.explanation"),
            scriptLicense: "MIT",
            siteURL: "https://greasyfork.org/en/scripts/423851-simple-youtube-age-restriction-bypass",
            scriptURL: "https://update.greasyfork.org/scripts/423851/Simple%20YouTube%20Age%20Restriction%20Bypass.user.js",
            defaultScript: true
        ),
        defaultGreasyScriptItem(
            scriptName: String(localized: "greasy.youtube.adblocker_2025-02-16.name"),
            scriptID: "youtube_adblocker_2025-02-16",
            coreSite: "youtube.com",
            scriptEnabled: true,
            scriptExplanation: String(localized: "greasy.youtube.adblocker_2025-02-16.explanation"),
            scriptLicense: "MIT",
            siteURL: "https://greasyfork.org/en/scripts/459541-youtube-adb",
            scriptURL: "https://update.greasyfork.org/scripts/459541/YouTube去广告.user.js",
            defaultScript: true
        ),
        defaultGreasyScriptItem(
            scriptName: String(localized: "greasy.x.contentwarning_2025-02-16.name"),
            scriptID: "x_contentwarning_2025-02-16",
            coreSite: "x.com",
            scriptEnabled: true,
            scriptExplanation: String(localized: "greasy.x.contentwarning_2025-02-16.explanation"),
            scriptLicense: "gpl-3-0",
            siteURL: "https://greasyfork.org/en/scripts/445650-twitter-remove-content-warning",
            scriptURL: "https://update.greasyfork.org/scripts/445650/Twitter%20Remove%20Content%20Warning.user.js",
            defaultScript: true
        ),
        defaultGreasyScriptItem(
            scriptName: String(localized: "greasy.instagram.adblocker_2025-02-16.name"),
            scriptID: "instagram_adblocker_2025-02-16",
            coreSite: "instagram.com",
            scriptEnabled: true,
            scriptExplanation: String(localized: "greasy.instagram.adblocker_2025-02-16.explanation"),
            scriptLicense: "MIT",
            siteURL: "https://greasyfork.org/en/scripts/510716-block-instagram-ads-and-suggested-posts",
            scriptURL: "https://update.greasyfork.org/scripts/510716/Block%20Instagram%20Ads%20and%20Suggested%20Posts.user.js",
            defaultScript: true
        ),
        defaultGreasyScriptItem(
            scriptName: String(localized: "greasy.linkedin.adblocker_2025-02-16.name"),
            scriptID: "linkedin_adblocker_2025-02-16",
            coreSite: "linkedin.com",
            scriptEnabled: true,
            scriptExplanation: String(localized: "greasy.linkedin.adblocker_2025-02-16.explanation"),
            scriptLicense: "n/a",
            siteURL: "https://greasyfork.org/en/scripts/386859-linkedinnopromoted",
            scriptURL: "https://update.greasyfork.org/scripts/386859/LinkedInNoPromoted.user.js",
            defaultScript: true
        ),
        defaultGreasyScriptItem(
            scriptName: String(localized: "greasy.duolingo.adblocker_2025-02-16.name"),
            scriptID: "duolingo_adblocker_2025-02-16",
            coreSite: "duolingo.com",
            scriptEnabled: true,
            scriptExplanation: String(localized: "greasy.duolingo.adblocker_2025-02-16.explanation"),
            scriptLicense: "n/a",
            siteURL: "https://greasyfork.org/en/scripts/501941-super-duolingo-ad-blocker",
            scriptURL: "https://update.greasyfork.org/scripts/501941/Super%20Duolingo%20Ad%20Blocker.user.js",
            defaultScript: true
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
            scriptURL: "",
            defaultScript: true
        ),
 */

    ]
}

