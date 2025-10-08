//
//  AdBlockSelect-VM.swift
//  qFocus Browser
//
//
import Foundation
import SwiftUI



@MainActor
class AdBlockSelectVM: ObservableObject {
    @Published var displayItems: [AdBlockFilterDisplayItem] = []

    private let adBlockFilterRepo: AdBlockFilterRepo

    

    init(adBlockFilterRepo: AdBlockFilterRepo, filterListService: AdBlockFilterListService = AllAdBlockFilterListItems()) {
        self.adBlockFilterRepo = adBlockFilterRepo

        let filters = filterListService.getAllFilters()
        initializeSettingsIfNeeded(filters: filters)

        loadItems()
    }
    


    //MARK: Load Items
    func loadItems() {
        displayItems = adBlockFilterRepo.getDisplayItems().sorted { $0.sortOrder < $1.sortOrder }
    }

    

    // MARK: isEnabled
    func isEnabled(filter: AdBlockFilterItem) -> Bool {
        return adBlockFilterRepo.getSetting(for: filter.filterID)?.enabled ?? filter.preSelectediOS
    }
    


    //MARK: Toggle
    func toggle(filterID: String, to newValue: Bool) {
        adBlockFilterRepo.addOrUpdateSetting(for: filterID, enabled: newValue)
    }
    
    
    
    // MARK: initializeSettingsIfNeeded
    private func initializeSettingsIfNeeded(filters: [AdBlockFilterItem]) {
        adBlockFilterRepo.initializeSettingsIfNeeded(for: filters)
    }
    
}

