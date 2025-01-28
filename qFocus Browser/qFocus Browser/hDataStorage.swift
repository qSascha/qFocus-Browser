//
//  hDataStorage.swift
//  qFocus Browser
//
//  Created by Sascha on 2024-12-11.
//

import SwiftData
import SwiftUI




//MARK: Settings Storage
enum navBarMode: String, CaseIterable, Codable {
    case bottom = "Bottom"
    case top = "Top"
    case freeFlow = "Free Flow"
}

@Model
class settingsStorage {
    var id: UUID = UUID()
    var navOption: navBarMode = navBarMode.bottom
    var opacity: Double = 0.7
    var enableAdBlock: Bool = true
    
    init(navOption: navBarMode, opacity: Double, enableAdBlock: Bool) {
        self.navOption = navOption
        self.opacity = opacity
        self.enableAdBlock = enableAdBlock
    }
    
}

func createDefaultSettings() -> [settingsStorage] {
    
    return [
        settingsStorage(
            navOption: .bottom,
            opacity: 0.7,
            enableAdBlock: true
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
    
    print("Successfully initialized \(defaultSettings.count) Record(s).")


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


    init(siteOrder: Int, siteName: String, siteURL: String, siteFavIcon: Data? = nil) {
        self.siteOrder = siteOrder
        self.siteName = siteName
        self.siteURL = siteURL
        self.siteFavIcon = siteFavIcon
    }
}

func createDefaultWebSites() -> [sitesStorage] {
    
    return [
        sitesStorage(
            siteOrder: 1,
            siteName: "",
            siteURL: "",
            siteFavIcon: UIImage(systemName: "exclamationmark.circle")?.pngData()
        ),
        sitesStorage(
            siteOrder: 2,
            siteName: "",
            siteURL: "",
            siteFavIcon: UIImage(systemName: "exclamationmark.circle")?.pngData()
        ),
        sitesStorage(
            siteOrder: 3,
            siteName: "",
            siteURL: "",
            siteFavIcon: UIImage(systemName: "exclamationmark.circle")?.pngData()
        ),
        sitesStorage(
            siteOrder: 4,
            siteName: "",
            siteURL: "",
            siteFavIcon: UIImage(systemName: "exclamationmark.circle")?.pngData()
        ),
        sitesStorage(
            siteOrder: 5,
            siteName: "",
            siteURL: "",
            siteFavIcon: UIImage(systemName: "exclamationmark.circle")?.pngData()
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
            recommended: false ,
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
            enabled: true
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
            enabled: true
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


