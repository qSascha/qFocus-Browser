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






//MARK: GreasyFork Scripts
@Model
final class greasyScripts {
    var id: UUID = UUID()
    var scriptName: String
    var coreSite: String
    var scriptEnabled: Bool
    var scriptExplanation: String
    var scriptLicense: String
    var siteURL: String
    var scriptURL: String
    
    init( scriptName: String, coreSite: String, scriptEnabled: Bool, scriptExplanation: String,scriptLicense: String, siteURL: String, scriptURL: String) {
        self.scriptName = scriptName
        self.coreSite = coreSite
        self.scriptEnabled = scriptEnabled
        self.scriptExplanation = scriptExplanation
        self.scriptLicense = scriptLicense
        self.siteURL = siteURL
        self.scriptURL = scriptURL
    }
    
}

func createGreasyScripts() -> [greasyScripts] {
    
    return [
        greasyScripts(
            scriptName: "Reddit: Ad Blocker",
            coreSite: "reddit.com",
            scriptEnabled: true,
            scriptExplanation: "Blocks the promoted content on Reddit between posts and also the advertisements on the side bar.",
            scriptLicense: "not specified",
            siteURL: "https://greasyfork.org/en/scripts/405756-reddit-promotion-blocker",
            scriptURL: "https://update.greasyfork.org/scripts/405756/Reddit%20Promotion%20Blocker.user.js"
        ),
        greasyScripts(
            scriptName: "X: Ad Blocker",
            coreSite: "x.com",
            scriptEnabled: true,
            scriptExplanation: "This short script looks for the text \"Ad\" or \"Promoted tweet\" in a specific label and removes both the promoted tweet and the large bold heading that is sometimes added just above it. It also removes promoted \"trending topics\" on the right side of the screen.",
            scriptLicense: "MIT",
            siteURL: "https://greasyfork.org/en/scripts/458669-remove-ads-and-promoted-tweets-on-twitter",
            scriptURL: "https://update.greasyfork.org/scripts/458669/Remove%20ads%20and%20promoted%20tweets%20on%20Twitter.user.js"
        ),
        greasyScripts(
            scriptName: "YouTube: Age Restriction",
            coreSite: "youtube.com",
            scriptEnabled: true,
            scriptExplanation: "Watch age restricted videos on YouTube without login and without age verification.",
            scriptLicense: "MIT",
            siteURL: "https://greasyfork.org/en/scripts/423851-simple-youtube-age-restriction-bypass",
            scriptURL: "https://update.greasyfork.org/scripts/423851/Simple%20YouTube%20Age%20Restriction%20Bypass.user.js"
        ),
        greasyScripts(
            scriptName: "Youtube: Ad Blocker",
            coreSite: "youtube.com",
            scriptEnabled: true,
            scriptExplanation: "A script to remove YouTube ads, including static ads and video ads.",
            scriptLicense: "MIT",
            siteURL: "https://greasyfork.org/en/scripts/459541-youtube-adb",
            scriptURL: "https://update.greasyfork.org/scripts/459541/YouTube去广告.user.js"
        ),
        greasyScripts(
            scriptName: "X: Content Warning",
            coreSite: "x.com",
            scriptEnabled: true,
            scriptExplanation: "Removes the content warning \"Sensitive Material\" and unhides the content",
            scriptLicense: "gpl-3-0",
            siteURL: "https://greasyfork.org/en/scripts/445650-twitter-remove-content-warning",
            scriptURL: "https://update.greasyfork.org/scripts/445650/Twitter%20Remove%20Content%20Warning.user.js"
        ),
        greasyScripts(
            scriptName: "Instagram: Ad Blocker",
            coreSite: "instagram.com",
            scriptEnabled: true,
            scriptExplanation: "Block Instagram posts with \"Follow\", \"Suggested for you\", or \"Suggested posts\".",
            scriptLicense: "MIT",
            siteURL: "https://greasyfork.org/en/scripts/510716-block-instagram-ads-and-suggested-posts",
            scriptURL: "https://update.greasyfork.org/scripts/510716/Block%20Instagram%20Ads%20and%20Suggested%20Posts.user.js"
        ),
        greasyScripts(
            scriptName: "LinkedIn",
            coreSite: "linkedin.com",
            scriptEnabled: true,
            scriptExplanation: "Removes promoted and suggested posts on LinkedIn.",
            scriptLicense: "n/a",
            siteURL: "https://greasyfork.org/en/scripts/386859-linkedinnopromoted",
            scriptURL: "https://update.greasyfork.org/scripts/386859/LinkedInNoPromoted.user.js"
        ),
        greasyScripts(
            scriptName: "Duolingo: Ad Blocker",
            coreSite: "duolingo.com",
            scriptEnabled: true,
            scriptExplanation: "Block ads and unwanted promotional content on Duolingo, including dynamically named ad classes, while preserving essential lesson content and handling fullscreen ads by pressing the exit button automatically or selecting \"No Thanks\" on specific ads.",
            scriptLicense: "n/a",
            siteURL: "https://greasyfork.org/en/scripts/501941-super-duolingo-ad-blocker",
            scriptURL: "https://update.greasyfork.org/scripts/501941/Super%20Duolingo%20Ad%20Blocker.user.js"
        )
        // ***************************************************************************************************************
/*
        greasyScripts(
            scriptName: "",
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

func initializeGreasyScripts(context: ModelContext) {

    let descriptor = FetchDescriptor<greasyScripts>()
    guard (try? context.fetch(descriptor))?.isEmpty ?? true else {
        print("GreasyFork scripts already exist, skipping initialization.")
        return
    }
    
    let greasyScripts = createGreasyScripts()
    for filter in greasyScripts {
        context.insert(filter)
    }
    
    try? context.save()
    
    print("Successfully initialized \(greasyScripts.count) GreasyFork scripts.")


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





//MARK: Ad-Block Filters Storage
@Model
class adBlockFilters {
    var id: UUID = UUID()
    var sortOrder: Int
    var preSelectediOS: Bool
    var preSelectedmacOS: Bool
    var urlString: String
    var identName: String
    var explanation: String
    var recommended: Bool
    var enabled: Bool

    init(sortOrder:Int, preSelectediOS: Bool, preSelectedmacOS: Bool, urlString: String, identName: String, explanation: String, recommended: Bool, enabled: Bool) {
        self.sortOrder = sortOrder
        self.preSelectediOS = preSelectediOS
        self.preSelectedmacOS = preSelectedmacOS
        self.urlString = urlString
        self.identName = identName
        self.explanation = explanation
        self.recommended = recommended
        self.enabled = enabled
    }
}

func createDefaultAdBlockFilters() -> [adBlockFilters] {
    
    return [
        adBlockFilters(
            sortOrder: 1,
            preSelectediOS: true,
            preSelectedmacOS: true,
            urlString: "https://filters.adtidy.org/extension/chromium-mv3/filters/24.txt",
            identName: "Quick fixes",
            explanation: "Used to quickly resolve critical content filtering issues on popular websites." ,
            recommended: true ,
            enabled: false
        ),
        adBlockFilters(
            sortOrder: 2,
            preSelectediOS: true,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_11_Mobile/filter.txt",
            identName: "Mobile ads filter",
            explanation: "Contains and blocks all known mobile ad networks." ,
            recommended: true ,
            enabled: false
        ),
        adBlockFilters(
            sortOrder: 3,
            preSelectediOS: true,
            preSelectedmacOS: true,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_3_Spyware/filter.txt",
            identName: "Tracking Protection",
            explanation: "List of web analytics tools. Use it to hide your actions online and avoid tracking." ,
            recommended: true ,
            enabled: true
        ),
        adBlockFilters(
            sortOrder: 4,
            preSelectediOS: true,
            preSelectedmacOS: true,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_4_Social/filter.txt",
            identName: "Social Media",
            explanation: "Removes numerous \"Like\" and \"Tweet\" buttons and other social media integrations." ,
            recommended: true ,
            enabled: true
        ),
        adBlockFilters(
            sortOrder: 5,
            preSelectediOS: true,
            preSelectedmacOS: true,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_14_Annoyances/filter.txt",
            identName: "Annoyances",
            explanation: "Blocks irritating elements, such as cookie notifications, popups, mobile app banners, widgets, etc." ,
            recommended: true ,
            enabled: true
        ),
        adBlockFilters(
            sortOrder: 6,
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_2_Base/filter.txt",
            identName: "English Filter",
            explanation: "Removes ads from websites with English content." ,
            recommended: true ,
            enabled: true
        ),
        adBlockFilters(
            sortOrder: 7,
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_6_German/filter.txt",
            identName: "German Filter",
            explanation: "Removes ads from websites with German content." ,
            recommended: false ,
            enabled: false
        ),
        adBlockFilters(
            sortOrder: 8,
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_224_Chinese/filter.txt",
            identName: "Chinese Filter",
            explanation: "Removes ads from websites with Chinese content." ,
            recommended: false ,
            enabled: false
        ),
        adBlockFilters(
            sortOrder: 9,
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_9_Spanish/filter.txt",
            identName: "Spanish/Portugese Filter",
            explanation: "Removes ads from websites with Spanish or Portugese content." ,
            recommended: false ,
            enabled: false
        ),
        adBlockFilters(
            sortOrder: 10,
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_7_Japanese/filter.txt",
            identName: "Japanese Filter",
            explanation: "Remove ads from websites with Japanese content." ,
            recommended: false ,
            enabled: false
        ),
        adBlockFilters(
            sortOrder: 11,
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_16_French/filter.txt",
            identName: "French Filter",
            explanation: "Removes ads from websites with French content." ,
            recommended: false ,
            enabled: false
        ),
        adBlockFilters(
            sortOrder: 12,
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_8_Dutch/filter.txt",
            identName: "Dutch Filter",
            explanation: "Remove ads from websites with Dutch content." ,
            recommended: false ,
            enabled: false
        ),
        adBlockFilters(
            sortOrder: 13,
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_23_Ukrainian/filter.txt",
            identName: "Ukrainian Filter",
            explanation: "Removes ads from websites with Ukrainian content." ,
            recommended: false ,
            enabled: false
        ),
        adBlockFilters(
            sortOrder: 14,
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_13_Turkish/filter.txt",
            identName: "Turkish Filter",
            explanation: "Removes ads from websites with Turkish content." ,
            recommended: false ,
            enabled: false
        ),
        adBlockFilters(
            sortOrder: 15,
            preSelectediOS: false,
            preSelectedmacOS: false,
            urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_1_Russian/filter.txt",
            identName: "Russian Filter",
            explanation: "Removes ads from websites with Russian content." ,
            recommended: false ,
            enabled: false
        )
    ]
}

func initializeFiltersStorage(context: ModelContext) {

    let descriptor = FetchDescriptor<adBlockFilters>()
    guard (try? context.fetch(descriptor))?.isEmpty ?? true else {
        print("Ad-Block filters already exist, skipping initialization")
        return
    }
    
    let defaultFilters = createDefaultAdBlockFilters()
    for filter in defaultFilters {
        context.insert(filter)
    }
    
    try? context.save()
    
    print("Successfully initialized \(defaultFilters.count) default Ad-Block filters")
}


