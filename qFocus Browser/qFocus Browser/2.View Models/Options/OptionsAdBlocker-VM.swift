//
//  OptionsAdBlocker-VM.swift
//  qFocus Browser
//
//
import Foundation
import SwiftUI



@MainActor
final class iOSAdBlockSettingsVM: ObservableObject {
    @ObservedObject var adBlockUC: AdBlockFilterUC
    let sitesRepo: SitesRepo
    let settingsRepo: SettingsRepo
    var adBlockFilterRepo: AdBlockFilterRepo
    
    @Published var isUpdating: Bool = false
    @Published var filterItems: [AdBlockFilterDisplayItem] = []
    @Published var iconSize: CGFloat = 32


    var adBlockUpdateFrequency: Binding<Int16> {
        Binding<Int16>(
            get: {
                self.settingsRepo.get().adBlockUpdateFrequency
            },
            set: { newValue in
                self.settingsRepo.update { settings in
                    settings.adBlockUpdateFrequency = newValue
                }
                CombineRepo.shared.updateWebSites.send()
            }
        )
    }
    
    var isAdBlockEnabled: Bool {
        if settingsRepo.get().adBlockUpdateFrequency > 0 {
            return true
        } else {
            return false
        }
    }
    


    //MARK: Init
    init(adBlockUC: AdBlockFilterUC, sitesRepo: SitesRepo, settingsRepo: SettingsRepo, adBlockFilterRepo: AdBlockFilterRepo) {
        self.adBlockUC = adBlockUC
        self.sitesRepo = sitesRepo
        self.settingsRepo = settingsRepo
        self.adBlockFilterRepo = adBlockFilterRepo
        
        filterItems = adBlockFilterRepo.getDisplayItems()
    }
    

    
    
    //MARK: Last Update Date
    func lastUpdateDate() -> String {
        if let date = settingsRepo.get().adBlockLastUpdate {
            return date.formatted(date: .abbreviated, time: .shortened)
        } else {
            return "never"
        }
    }
   
    
    
    //MARK: Toggle List Item
    func toggleListItem(for filter: AdBlockFilterDisplayItem) -> Binding<Bool> {
        Binding(
            get: {
                self.adBlockFilterRepo.getSetting(for: filter.filterID)?.enabled ?? filter.preSelectediOS
            },
            set: { newValue in
                self.adBlockFilterRepo.addOrUpdateSetting(for: filter.filterID, enabled: newValue)
                Collector.shared.save(event: "Setting", parameter: "AdBlockFilter-\(filter.filterID): \(newValue)")
            }
        )
    }
    

    
    //MARK: Update Now Button
    func updateNow() async {
        adBlockUC.compileAdBlockLists(manually: true)
        Collector.shared.save(event: "Setting", parameter: "AdBlockFilter-Update-Manual")
}
    
    
    
    //MARK: reorderAdBlockList
    func reorderAdBlockList(adBlockLists: [AdBlockFilterDisplayItem]) -> [AdBlockFilterDisplayItem] {
        let deviceLanguage = String(Locale.preferredLanguages[0].prefix(2))
        var reorderedList = adBlockLists
        if let index = reorderedList.firstIndex(where: { $0.languageCode == deviceLanguage }) {
            let languageItem = reorderedList.remove(at: index)
            languageItem.preSelectediOS = true
            reorderedList.insert(languageItem, at: 5)
        }
        return reorderedList
    }
   
}
