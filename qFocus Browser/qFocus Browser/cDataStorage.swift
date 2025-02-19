//
//  cDataStorage.swift
//  qFocus Browser
//
//  Created by Sascha on 2024-12-11.
//

import SwiftData
import SwiftUI




//MARK: Settings-Storage
@Model
class settingsStorage {
    var id: UUID = UUID()
    var enableAdBlock: Bool = true
    var freeFlowXPercent: Double
    var freeFlowYPercent: Double
    var showNavBar: Bool = false
    var adBlockLastUpdate: Date?
    var faceIDEnabled: Bool = false
    
    init( enableAdBlock: Bool, freeFlowXPercent: Double, freeFlowYPercent: Double, showNavBar: Bool, adBlockLastUpdate: Date, faceIDEnabled: Bool) {
        self.enableAdBlock = enableAdBlock
        self.freeFlowXPercent = freeFlowXPercent
        self.freeFlowYPercent = freeFlowYPercent
        self.showNavBar = showNavBar
        self.adBlockLastUpdate = adBlockLastUpdate
        self.faceIDEnabled = faceIDEnabled
    }
    
}

func createDefaultSettings() -> [settingsStorage] {
    
    return [
        settingsStorage(
            enableAdBlock: true,
            freeFlowXPercent: 0.85,
            freeFlowYPercent: 0.90,
            showNavBar: false,
            adBlockLastUpdate: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
            faceIDEnabled: false
        )
    ]
}

func initializeDefaultSettings(context: ModelContext) {

    let descriptor = FetchDescriptor<settingsStorage>()
    guard (try? context.fetch(descriptor))?.isEmpty ?? true else {
        print("Settings storage already exist, skipping initialization.")
        return
    }
    
    let defaultSettings = createDefaultSettings()
    for filter in defaultSettings {
        context.insert(filter)
    }
    
    try? context.save()
    
    print("Successfully initialized \(defaultSettings.count) Settings record.")


}






//MARK: GreasyFork Script Setting
@Model
final class greasyScriptSetting {
    var id: UUID = UUID()
    var scriptID: String
    var scriptEnabled: Bool
    
    init( scriptID: String, scriptEnabled: Bool) {
        self.scriptID = scriptID
        self.scriptEnabled = scriptEnabled
    }
    
}






//MARK: Greasy Scripts List
struct greasyScriptItem {
    var id: UUID = UUID()
    var scriptName: String
    var scriptID: String
    var coreSite: String
    var scriptEnabled: Bool
    var scriptExplanation: String
    var scriptLicense: String
    var siteURL: String
    var scriptURL: String
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







//MARK: Sites Storage
@Model
class sitesStorage {
    var id: UUID = UUID()
    var siteOrder: Int
    var siteName: String
    var siteURL: String

    @Attribute(.externalStorage)
    var siteFavIcon: Data?
    
    var enableJSBlocker: Bool
    var requestDesktop: Bool


    init(siteOrder: Int, siteName: String, siteURL: String, siteFavIcon: Data? = nil, enableJSBlocker: Bool, requestDesktop: Bool) {
        self.siteOrder = siteOrder
        self.siteName = siteName
        self.siteURL = siteURL
        self.siteFavIcon = siteFavIcon
        self.enableJSBlocker = enableJSBlocker
        self.requestDesktop = requestDesktop
    }
}

func createDefaultWebSites() -> [sitesStorage] {
    
    return [
        sitesStorage(
            siteOrder: 1,
            siteName: "",
            siteURL: "",
            siteFavIcon: UIImage(systemName: "exclamationmark.circle")?.pngData(),
            enableJSBlocker: true,
            requestDesktop: false
        ),
        sitesStorage(
            siteOrder: 2,
            siteName: "",
            siteURL: "",
            siteFavIcon: UIImage(systemName: "exclamationmark.circle")?.pngData(),
            enableJSBlocker: true,
            requestDesktop: false

        ),
        sitesStorage(
            siteOrder: 3,
            siteName: "",
            siteURL: "",
            siteFavIcon: UIImage(systemName: "exclamationmark.circle")?.pngData(),
            enableJSBlocker: true,
            requestDesktop: false

        ),
        sitesStorage(
            siteOrder: 4,
            siteName: "",
            siteURL: "",
            siteFavIcon: UIImage(systemName: "exclamationmark.circle")?.pngData(),
            enableJSBlocker: true,
            requestDesktop: false

        ),
        sitesStorage(
            siteOrder: 5,
            siteName: "",
            siteURL: "",
            siteFavIcon: UIImage(systemName: "exclamationmark.circle")?.pngData(),
            enableJSBlocker: true,
            requestDesktop: false

        ),
        sitesStorage(
            siteOrder: 6,
            siteName: "",
            siteURL: "",
            siteFavIcon: UIImage(systemName: "exclamationmark.circle")?.pngData(),
            enableJSBlocker: true,
            requestDesktop: false

        )
    ]
}

func initializeWebSitesStorage(context: ModelContext) {

    let descriptor = FetchDescriptor<sitesStorage>()
    guard (try? context.fetch(descriptor))?.isEmpty ?? true else {
        print("WebSites storage already exist, skipping initialization.")
        return
    }
    
    let defaultSites = createDefaultWebSites()
    for filter in defaultSites {
        context.insert(filter)
    }
    
    try? context.save()
    
    print("Successfully initialized \(defaultSites.count) empty WebSites.")


}





//MARK: Ad-Block Filter Setting
@Model
class adBlockFilterSetting {
    var id: UUID = UUID()
    var filterID: String
    var enabled: Bool

    init(filterID: String, enabled: Bool) {
        self.filterID = filterID
        self.enabled = enabled
    }
}








//MARK: Ad Block Filter Array
struct AdBlockFilterItem: Identifiable {
    let id: String
    let sortOrder: Int
    let filterID: String
    let preSelectediOS: Bool
    let preSelectedmacOS: Bool
    let urlString: String
    let languageCode: String
    let identName: String
    let explanation: String
    
    init(sortOrder: Int, filterID: String, preSelectediOS: Bool, preSelectedmacOS: Bool, urlString: String, languageCode: String, identName: String, explanation: String, enabled: Bool = false) {
        self.id = filterID  // Use filterID as id
        self.sortOrder = sortOrder
        self.filterID = filterID
        self.preSelectediOS = preSelectediOS
        self.preSelectedmacOS = preSelectedmacOS
        self.urlString = urlString
        self.languageCode = languageCode
        self.identName = identName
        self.explanation = explanation
    }
    
}



func createAdBlockFilterList() -> [AdBlockFilterItem] {
    return [
        AdBlockFilterItem(
            sortOrder: 1,
            filterID: "quick_fixes",
            preSelectediOS: true,
            preSelectedmacOS: true,
            urlString: "https://filters.adtidy.org/extension/chromium-mv3/filters/24.txt",
            languageCode: "",
            identName: String(localized: "adblocklist.quick_fixes.name"),
            explanation: String(localized: "adblocklist.quick_fixes.explanation")
        ),
        AdBlockFilterItem(
            sortOrder: 2,
            filterID: "mobile_ads",
            preSelectediOS: true,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_11_Mobile/filter.txt",
            languageCode: "",
            identName: String(localized: "adblocklist.mobile_ads.name"),
            explanation: String(localized: "adblocklist.mobile_ads.explanation")
        ),
        AdBlockFilterItem(
            sortOrder: 3,
            filterID: "tracking_protection",
            preSelectediOS: true,
            preSelectedmacOS: true,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_3_Spyware/filter.txt",
            languageCode: "",
            identName: String(localized: "adblocklist.tracking_protection.name"),
            explanation: String(localized: "adblocklist.tracking_protection.explanation")
        ),
        AdBlockFilterItem(
            sortOrder: 4,
            filterID: "social_media",
            preSelectediOS: true,
            preSelectedmacOS: true,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_4_Social/filter.txt",
            languageCode: "",
            identName: String(localized: "adblocklist.social_media.name"),
            explanation: String(localized: "adblocklist.social_media.explanation")
        ),
        AdBlockFilterItem(
            sortOrder: 5,
            filterID: "annoyances",
            preSelectediOS: true,
            preSelectedmacOS: true,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_14_Annoyances/filter.txt",
            languageCode: "",
            identName: String(localized: "adblocklist.annoyances.name"),
            explanation: String(localized: "adblocklist.annoyances.explanation")
        ),
        AdBlockFilterItem(
            sortOrder: 6,
            filterID: "language_english",
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_2_Base/filter.txt",
            languageCode: "en",
            identName: String(localized: "adblocklist.language_english.name"),
            explanation: String(localized: "adblocklist.language_english.explanation")
        ),
        AdBlockFilterItem(
            sortOrder: 7,
            filterID: "language_german",
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_6_German/filter.txt",
            languageCode: "de",
            identName: String(localized: "adblocklist.language_german.name"),
            explanation: String(localized: "adblocklist.language_german.explanation")
        ),
        AdBlockFilterItem(
            sortOrder: 8,
            filterID: "language_chinese",
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_224_Chinese/filter.txt",
            languageCode: "",
            identName: String(localized: "adblocklist.language_chinese.name"),
            explanation: String(localized: "adblocklist.language_chinese.explanation")
        ),
        AdBlockFilterItem(
            sortOrder: 9,
            filterID: "language_spanish",
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_9_Spanish/filter.txt",
            languageCode: "es",
            identName: String(localized: "adblocklist.language_spanish.name"),
            explanation: String(localized: "adblocklist.language_spanish.explanation")
        ),
        AdBlockFilterItem(
            sortOrder: 10,
            filterID: "language_portuguese",
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_9_Spanish/filter.txt",
            languageCode: "pt",
            identName: String(localized: "adblocklist.language_portuguese.name"),
            explanation: String(localized: "adblocklist.language_portuguese.explanation")
        ),
        AdBlockFilterItem(
            sortOrder: 11,
            filterID: "language_japanese",
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_7_Japanese/filter.txt",
            languageCode: "",
            identName: String(localized: "adblocklist.language_japanese.name"),
            explanation: String(localized: "adblocklist.language_japanese.explanation")
        ),
        AdBlockFilterItem(
            sortOrder: 12,
            filterID: "language_french",
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_16_French/filter.txt",
            languageCode: "",
            identName: String(localized: "adblocklist.language_french.name"),
            explanation: String(localized: "adblocklist.language_french.explanation")
        ),
        AdBlockFilterItem(
            sortOrder: 13,
            filterID: "language_dutch",
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_8_Dutch/filter.txt",
            languageCode: "",
            identName: String(localized: "adblocklist.language_dutch.name"),
            explanation: String(localized: "adblocklist.language_dutch.explanation")
        ),
        AdBlockFilterItem(
            sortOrder: 14,
            filterID: "language_ukrainian",
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_23_Ukrainian/filter.txt",
            languageCode: "",
            identName: String(localized: "adblocklist.language_ukrainian.name"),
            explanation: String(localized: "adblocklist.language_ukrainian.explanation")
        ),
        AdBlockFilterItem(
            sortOrder: 15,
            filterID: "language_turkish",
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_13_Turkish/filter.txt",
            languageCode: "",
            identName: String(localized: "adblocklist.language_turkish.name"),
            explanation: String(localized: "adblocklist.language_turkish.explanation")
        ),
        AdBlockFilterItem(
            sortOrder: 16,
            filterID: "language_russian",
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_1_Russian/filter.txt",
            languageCode: "",
            identName: String(localized: "adblocklist.language_russian.name"),
            explanation: String(localized: "adblocklist.language_russian.explanation")
        )
    ]
}
