//
//  Options-VM.swift
//  qFocus Browser
//
//
import SwiftUI
import Combine



@MainActor
final class OptionsVM: ObservableObject {
    let sitesRepo: SitesRepo
    let settingsRepo: SettingsRepo
    let adBlockFilterRepo: AdBlockFilterRepo
    let settings: SettingsStorage

    @Published var sites: [SitesStorage] = []
    @Published var externalURL: IdentifiableURL? = nil

    let iconSize: CGFloat = 30
    let maxSites: Int = 6
    
    private var cancellables = Set<AnyCancellable>()
    
    
    var enabledFilterCount: Int {
        adBlockFilterRepo.getAllEnabled().count
    }
    
    


    //MARK: Init
    init(sitesRepo: SitesRepo, settingsRepo: SettingsRepo, adBlockFilterRepo: AdBlockFilterRepo) {
        self.sitesRepo = sitesRepo
        self.settingsRepo = settingsRepo
        self.adBlockFilterRepo = adBlockFilterRepo
        
        self.settings = settingsRepo.get()
        
        refreshSites()

        // Update Web Views - triggered by adding or removing a site
        CombineRepo.shared.updateWebSites
            .sink { [weak self] _ in
                self?.refreshSites()
            } .store(in: &cancellables)

    }
    
    

    //MARK: FaceID Enabled
    var faceIDEnabled: Bool {
        get { settings.faceIDEnabled }
        set {
            settingsRepo.update { settings in
                settings.faceIDEnabled = newValue
            }
        }
    }
    

    
    //MARK: AdBlock Update Frequency
    var adBlockUpdateFrequency: Int16 {
        get { settings.adBlockUpdateFrequency }
        set {
            settingsRepo.update { settings in
                settings.adBlockUpdateFrequency = newValue
            }
        }
    }
    

    
    //MARK: Refresh Sites
    func refreshSites() {
        sites = sitesRepo.getAllSites().sorted(by: { $0.siteOrder < $1.siteOrder })
    }
    
    

    
    //MARK: Can Add Site
    func canAddSite() -> Bool {
        return sites.count < maxSites
    }
    
    

    //MARK: Remaining Slots
    func remainingSlots() -> Int {
        return maxSites - sites.count
    }
    


    //MARK: Persist Site Order
    func persistSiteOrder() {
        sitesRepo.persistSiteOrder(sites: sites)
    }



    //MARK: Save
    func save() {
        settingsRepo.save()
    }

}

