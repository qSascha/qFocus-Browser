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
            scriptName: "reddit_adblocker_2025-02-16_name".localized,
            scriptID: "reddit_adblocker_2025-02-16",
            coreSite: "reddit.com",
            scriptEnabled: true,
            scriptExplanation: "reddit_adblocker_2025-02-16_explanation".localized,
            scriptLicense: "not specified",
            siteURL: "https://greasyfork.org/en/scripts/405756-reddit-promotion-blocker",
            scriptURL: "https://update.greasyfork.org/scripts/405756/Reddit%20Promotion%20Blocker.user.js"
        ),
        greasyScriptItem(
            scriptName: "x_adblocker_2025-02-16_name".localized,
            scriptID: "x_adblocker_2025-02-16",
            coreSite: "x.com",
            scriptEnabled: true,
            scriptExplanation: "x_adblocker_2025-02-16_explanation".localized,
            scriptLicense: "MIT",
            siteURL: "https://greasyfork.org/en/scripts/458669-remove-ads-and-promoted-tweets-on-twitter",
            scriptURL: "https://update.greasyfork.org/scripts/458669/Remove%20ads%20and%20promoted%20tweets%20on%20Twitter.user.js"
        ),
        greasyScriptItem(
            scriptName: "youtube_agerestriction_2025-02-16_name".localized,
            scriptID: "youtube_agerestriction_2025-02-16",
            coreSite: "youtube.com",
            scriptEnabled: true,
            scriptExplanation: "youtube_agerestriction_2025-02-16_explanation".localized,
            scriptLicense: "MIT",
            siteURL: "https://greasyfork.org/en/scripts/423851-simple-youtube-age-restriction-bypass",
            scriptURL: "https://update.greasyfork.org/scripts/423851/Simple%20YouTube%20Age%20Restriction%20Bypass.user.js"
        ),
        greasyScriptItem(
            scriptName: "youtube_adblocker_2025-02-16_name".localized,
            scriptID: "youtube_adblocker_2025-02-16",
            coreSite: "youtube.com",
            scriptEnabled: true,
            scriptExplanation: "youtube_adblocker_2025-02-16_explanation".localized,
            scriptLicense: "MIT",
            siteURL: "https://greasyfork.org/en/scripts/459541-youtube-adb",
            scriptURL: "https://update.greasyfork.org/scripts/459541/YouTube去广告.user.js"
        ),
        greasyScriptItem(
            scriptName: "x_contentwarning_2025-02-16_name".localized,
            scriptID: "x_contentwarning_2025-02-16",
            coreSite: "x.com",
            scriptEnabled: true,
            scriptExplanation: "x_contentwarning_2025-02-16_explanation".localized,
            scriptLicense: "gpl-3-0",
            siteURL: "https://greasyfork.org/en/scripts/445650-twitter-remove-content-warning",
            scriptURL: "https://update.greasyfork.org/scripts/445650/Twitter%20Remove%20Content%20Warning.user.js"
        ),
        greasyScriptItem(
            scriptName: "instagram_adblocker_2025-02-16_name".localized,
            scriptID: "instagram_adblocker_2025-02-16",
            coreSite: "instagram.com",
            scriptEnabled: true,
            scriptExplanation: "instagram_adblocker_2025-02-16_explanation".localized,
            scriptLicense: "MIT",
            siteURL: "https://greasyfork.org/en/scripts/510716-block-instagram-ads-and-suggested-posts",
            scriptURL: "https://update.greasyfork.org/scripts/510716/Block%20Instagram%20Ads%20and%20Suggested%20Posts.user.js"
        ),
        greasyScriptItem(
            scriptName: "linkedin_adblocker_2025-02-16_name".localized,
            scriptID: "linkedin_adblocker_2025-02-16",
            coreSite: "linkedin.com",
            scriptEnabled: true,
            scriptExplanation: "linkedin_adblocker_2025-02-16_explanation".localized,
            scriptLicense: "n/a",
            siteURL: "https://greasyfork.org/en/scripts/386859-linkedinnopromoted",
            scriptURL: "https://update.greasyfork.org/scripts/386859/LinkedInNoPromoted.user.js"
        ),
        greasyScriptItem(
            scriptName: "duolingo_adblocker_2025-02-16_name".localized,
            scriptID: "duolingo_adblocker_2025-02-16",
            coreSite: "duolingo.com",
            scriptEnabled: true,
            scriptExplanation: "duolingo_adblocker_2025-02-16_explanation".localized,
            scriptLicense: "n/a",
            siteURL: "https://greasyfork.org/en/scripts/501941-super-duolingo-ad-blocker",
            scriptURL: "https://update.greasyfork.org/scripts/501941/Super%20Duolingo%20Ad%20Blocker.user.js"
        )
        // ***************************************************************************************************************
/*
        greasyScriptItem(
            scriptName: "",
            scriptID: "__2025-xx-yy",
            coreSite: "",
            scriptEnabled: true,
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
    let identName: String
    let explanation: String
    
    init(sortOrder: Int, filterID: String, preSelectediOS: Bool, preSelectedmacOS: Bool, urlString: String, identName: String, explanation: String, enabled: Bool = false) {
        self.id = filterID  // Use filterID as id
        self.sortOrder = sortOrder
        self.filterID = filterID
        self.preSelectediOS = preSelectediOS
        self.preSelectedmacOS = preSelectedmacOS
        self.urlString = urlString
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
            identName: "quick_fixes_name".localized,
            explanation: "quick_fixes_explanation".localized
        ),
        AdBlockFilterItem(
            sortOrder: 2,
            filterID: "mobile_ads",
            preSelectediOS: true,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_11_Mobile/filter.txt",
            identName: "mobile_ads_name".localized,
            explanation: "mobile_ads_explanation".localized
        ),
        AdBlockFilterItem(
            sortOrder: 3,
            filterID: "tracking_protection",
            preSelectediOS: true,
            preSelectedmacOS: true,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_3_Spyware/filter.txt",
            identName: "tracking_protection_name".localized,
            explanation: "tracking_protection_explanation".localized
        ),
        AdBlockFilterItem(
            sortOrder: 4,
            filterID: "social_media",
            preSelectediOS: true,
            preSelectedmacOS: true,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_4_Social/filter.txt",
            identName: "social_media_name".localized,
            explanation: "social_media_explanation".localized
        ),
        AdBlockFilterItem(
            sortOrder: 5,
            filterID: "annoyances",
            preSelectediOS: true,
            preSelectedmacOS: true,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_14_Annoyances/filter.txt",
            identName: "annoyances_name".localized,
            explanation: "annoyances_explanation".localized
        ),
        AdBlockFilterItem(
            sortOrder: 6,
            filterID: "language_english",
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_2_Base/filter.txt",
            identName: "language_english_name".localized,
            explanation: "language_english_explanation".localized
        ),
        AdBlockFilterItem(
            sortOrder: 7,
            filterID: "language_german",
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_6_German/filter.txt",
            identName: "language_german_name".localized,
            explanation: "language_german_explanation".localized
        ),
        AdBlockFilterItem(
            sortOrder: 8,
            filterID: "language_chinese",
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_224_Chinese/filter.txt",
            identName: "language_chinese_name".localized,
            explanation: "language_chinese_explanation".localized
        ),
        AdBlockFilterItem(
            sortOrder: 9,
            filterID: "language_spanish",
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_9_Spanish/filter.txt",
            identName: "language_spanish_name".localized,
            explanation: "language_spanish_explanation".localized
        ),
        AdBlockFilterItem(
            sortOrder: 10,
            filterID: "language_japanese",
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_7_Japanese/filter.txt",
            identName: "language_japanese_name".localized,
            explanation: "language_japanese_explanation".localized
        ),
        AdBlockFilterItem(
            sortOrder: 11,
            filterID: "language_french",
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_16_French/filter.txt",
            identName: "language_french".localized,
            explanation: "language_french_explanation".localized
        ),
        AdBlockFilterItem(
            sortOrder: 12,
            filterID: "language_dutch",
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_8_Dutch/filter.txt",
            identName: "language_dutch_name".localized,
            explanation: "language_dutch_explanation".localized
        ),
        AdBlockFilterItem(
            sortOrder: 13,
            filterID: "language_ukrainian",
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_23_Ukrainian/filter.txt",
            identName: "language_ukrainian_name".localized,
            explanation: "language_ukrainian_explanation".localized
        ),
        AdBlockFilterItem(
            sortOrder: 14,
            filterID: "language_turkish",
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_13_Turkish/filter.txt",
            identName: "language_turkish_name".localized,
            explanation: "language_turkish_explanation".localized
        ),
        AdBlockFilterItem(
            sortOrder: 15,
            filterID: "language_russian",
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_1_Russian/filter.txt",
            identName: "language_russian_name".localized,
            explanation: "language_russian_explanation".localized
        )
    ]
}
