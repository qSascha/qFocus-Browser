//
//  OptionsAdBlocker-VM.swift
//  qFocus Browser
//
//
import Foundation
import SwiftUI



@MainActor
final class iOSAdBlockSettingsVM: ObservableObject {
    let adBlockUC: AdBlockFilterUC
    let sitesRepo: SitesRepo
    let settingsRepo: SettingsRepo
    var adBlockFilterRepo: AdBlockFilterRepo
    
    @Published var filterItems: [AdBlockFilterDisplayItem] = []


    
    var enableAdBlockToggle: Binding<Bool> {
        Binding<Bool>(
            get: {
                self.settingsRepo.get().enableAdBlock
            },
            set: { newValue in
                self.settingsRepo.update { settings in
                    settings.enableAdBlock = newValue
                }
                CombineRepo.shared.updateWebSites.send()
            }
        )
    }
    
    var isAdBlockEnabled: Bool {
        settingsRepo.get().enableAdBlock
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
            }
        )
    }
    

    
    //MARK: Update Now Button
    func updateNow() async {
        adBlockUC.compileAdBlockLists()

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
