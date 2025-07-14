//
//  StartView-VM.swift
//  qFocus Browser
//
//
import Foundation
import UIKit
import SwiftUI



@MainActor
class StartVM: ObservableObject {
    @Published var adBlockRepo: AdBlockFilterRepo
    @Published var settingsRepo: SettingsRepo
    @Published var sitesRepo: SitesRepo

    @Published var state: StartViewState = .initial
    

    
    
    //MARK: Init
    init(adBlockRepo: AdBlockFilterRepo, settingsRepo: SettingsRepo, sitesRepo: SitesRepo) {
        self.adBlockRepo = adBlockRepo
        self.settingsRepo = settingsRepo
        self.sitesRepo = sitesRepo


        evaluateStartup()

        #if DEBUG
        let sites = sitesRepo.getAllSites()
        for site in sites {
            print("Stored site: \(site.siteOrder) - \(site.siteName)")
        }
        print("-----------------------------------------------------------")
        let allFilters = adBlockRepo.getAllSettings()
        for filter in allFilters where filter.enabled {
            print("Enabled ad block filter: \(filter.filterID)")
        }
        print("-----------------------------------------------------------")

        let settings = settingsRepo.get()
        print("🔧 Settings:")
//        print("• AdBlock Frequency: \(settings.adBlockUpdateFrequency)")
        print("• freeFlowXPercent: \(settings.freeFlowXPercent)")
        print("• freeFlowYPercent: \(settings.freeFlowYPercent)")
        print("• adBlockLastUpdate: \(settings.adBlockLastUpdate?.description ?? "nil")")
        print("• faceIDEnabled: \(settings.faceIDEnabled)")
        print("• onboardingComplete: \(settings.onboardingComplete)")
        #endif

    }

    
    
    //MARK: Evaluate Startup
    func evaluateStartup() {
        print("Onboarding Complete - Step 3 -----------------------------------------")
        let settings = settingsRepo.get()
        let onboardingCompleted = settings.onboardingComplete

        let platform = DeviceInfo.shared.platform

        if !onboardingCompleted {
            self.state = .onboarding(platform)
        } else {
            print("Onboarding Complete - Step 4 -----------------------------------------")
            self.state = .loading(platform)
        }
    }
    
    
    //MARK: Move to Main
    func moveToMain(platform: AppPlatform) {
        self.state = .main(platform)
    }

}
