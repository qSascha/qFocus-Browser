//
//  AdBlockFilter-Repo.swift
//  qFocus Browser
//
//
import Foundation
import CoreData



final class AdBlockFilterRepo: ObservableObject {
    let context: NSManagedObjectContext
    


    // MARK: init
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    
    
    
    // MARK: getAllSettings
    func getAllSettings() -> [AdBlockFilterSetting] {
        let request: NSFetchRequest<AdBlockFilterSetting> = AdBlockFilterSetting.fetchRequest()
        return (try? context.fetch(request)) ?? []
    }
    
    
    
    // MARK: getAllEnabled
    func getAllEnabled() -> [AdBlockFilterSetting] {
        let request: NSFetchRequest<AdBlockFilterSetting> = AdBlockFilterSetting.fetchRequest()
        request.predicate = NSPredicate(format: "enabled == YES")
        return (try? context.fetch(request)) ?? []
    }
    
    
    
    // MARK: getSetting
    func getSetting(for filterID: String) -> AdBlockFilterSetting? {
        let request: NSFetchRequest<AdBlockFilterSetting> = AdBlockFilterSetting.fetchRequest()
        request.predicate = NSPredicate(format: "filterID == %@", filterID)
        return try? context.fetch(request).first
    }
  
    
    
    // MARK: addOrUpdateSetting only used in Onboarding - AdBlockSelect
    func addOrUpdateSetting(for filterID: String, enabled: Bool, checksum: String? = nil) {
        if let existingSetting = getSetting(for: filterID) {
            existingSetting.enabled = enabled
            if let checksum = checksum {
                existingSetting.checksum = checksum
            }
    #if DEBUG
            print("🔄 Updated setting for \(filterID) to enabled: \(enabled), checksum: \(checksum ?? "(unchanged)")")
    #endif
        } else {
            let newSetting = AdBlockFilterSetting(context: context)
            newSetting.id = UUID()
            newSetting.filterID = filterID
            newSetting.enabled = enabled
            newSetting.checksum = checksum ?? ""
    #if DEBUG
            print("➕ Created new setting for \(filterID) with enabled: \(enabled), checksum: \(checksum ?? "(empty)")")
    #endif
        }
        try? context.save()
    }

    
    
    // MARK: initializeSettingsIfNeeded
    func initializeSettingsIfNeeded(for filters: [AdBlockFilterItem]) {
        for filter in filters {
            if getSetting(for: filter.filterID) == nil {
                let newSetting = AdBlockFilterSetting(context: context)
                newSetting.id = UUID()
                newSetting.filterID = filter.filterID
                newSetting.enabled = filter.preSelectediOS
#if DEBUG
                print("✨ Initialized setting for \(filter.identName)")
#endif
            }
        }
        try? context.save()
    }

    
    
    // Get Display Items
    func getDisplayItems() -> [AdBlockFilterDisplayItem] {
        let settings = getAllSettings().reduce(into: [String: AdBlockFilterSetting]()) { dict, setting in
            dict[setting.filterID] = setting
        }
        
        return AllAdBlockFilterListItems().getAllFilters().map { item in
            //TODO: check for macOS: preSelectediOS
            let enabled = settings[item.filterID]?.enabled ?? item.preSelectediOS
            let displayItem = AdBlockFilterDisplayItem()
            displayItem.sortOrder = item.sortOrder
            displayItem.filterID = item.filterID
            displayItem.preSelectediOS = item.preSelectediOS
            displayItem.identName = item.identName
            displayItem.explanation = item.explanation
            displayItem.enabled = enabled
            return displayItem
        }
    }

}









//******************************************


//MARK: AdBlockFilterListService
protocol AdBlockFilterListService {
    func getAllFilters() -> [AdBlockFilterItem]
}

class AllAdBlockFilterListItems: AdBlockFilterListService {
    func getAllFilters() -> [AdBlockFilterItem] {
        return [
            AdBlockFilterItem(
                sortOrder: 1,
                filterID: "base_filter",
                preSelectediOS: true,
                preSelectedmacOS: true,
                urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_2_Base/filter.txt",
                languageCode: "",
                identName: String(localized: "adblocklist.base_filter.name"),
                explanation: String(localized: "adblocklist.base_filter.explanation")
            ),
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
                languageCode: "zh",
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
                languageCode: "ja",
                identName: String(localized: "adblocklist.language_japanese.name"),
                explanation: String(localized: "adblocklist.language_japanese.explanation")
            ),
            AdBlockFilterItem(
                sortOrder: 12,
                filterID: "language_french",
                preSelectediOS: false,
                preSelectedmacOS: false,
                urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_16_French/filter.txt",
                languageCode: "fr",
                identName: String(localized: "adblocklist.language_french.name"),
                explanation: String(localized: "adblocklist.language_french.explanation")
            ),
            AdBlockFilterItem(
                sortOrder: 13,
                filterID: "language_dutch",
                preSelectediOS: false,
                preSelectedmacOS: false,
                urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_8_Dutch/filter.txt",
                languageCode: "nl",
                identName: String(localized: "adblocklist.language_dutch.name"),
                explanation: String(localized: "adblocklist.language_dutch.explanation")
            ),
            AdBlockFilterItem(
                sortOrder: 14,
                filterID: "language_ukrainian",
                preSelectediOS: false,
                preSelectedmacOS: false,
                urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_23_Ukrainian/filter.txt",
                languageCode: "uk",
                identName: String(localized: "adblocklist.language_ukrainian.name"),
                explanation: String(localized: "adblocklist.language_ukrainian.explanation")
            ),
            AdBlockFilterItem(
                sortOrder: 15,
                filterID: "language_russian",
                preSelectediOS: false,
                preSelectedmacOS: false,
                urlString: "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_1_Russian/filter.txt",
                languageCode: "ru",
                identName: String(localized: "adblocklist.language_russian.name"),
                explanation: String(localized: "adblocklist.language_russian.explanation")
            )
        ]
    }
}
