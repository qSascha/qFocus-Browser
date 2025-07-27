//
//  Navigation-VM.swift
//  qFocus Browser
//
//
import Foundation
import Combine



@MainActor
class NavigationVM: ObservableObject {
    @Published var sitesRepo: SitesRepo
    @Published var settingsRepo: SettingsRepo
    
    @Published private(set) var webSites: [SitesStorage] = []

    @Published var updateXPercent: CGFloat = 0.85
    @Published var updateYPercent: CGFloat = 0.75
    @Published var isShowingMenu: Bool = false
    @Published var selectedWebIndex: Int = 0
    @Published var sitesButton: [SitesNavButton] = []
    @Published var minimizeNavBar: Bool = false

    var showShareSheet = false
    var menuIconSize: CGFloat = 32

    private var cancellables = Set<AnyCancellable>()
    
    
    
    //MARK: init
    init(sitesRepo: SitesRepo, settingsRepo: SettingsRepo) {
        self.sitesRepo = sitesRepo
        self.settingsRepo = settingsRepo
 
        loadWebSites()
        loadFreeFlowPositions()

        // Update when drag&drop in Options
        CombineRepo.shared.updateWebSites
            .sink { [weak self] in
                Task { @MainActor in
                    self?.loadWebSites()
                }
            }.store(in: &cancellables)

        // Update when webview scrolling
        CombineRepo.shared.updateNavigationBar
            .sink { [weak self] hide in
//                print("Scrolling received: \(hide)")
                self?.minimizeNavBar = hide
            }
            .store(in: &cancellables)

    }
    


    //MARK: Load Web Sites
    private func loadWebSites() {
        self.webSites.removeAll()
        self.webSites = self.sitesRepo.getAllSites()


        var newDetails: [SitesNavButton] = []
        for site in webSites {
            let details = SitesNavButton(id: UUID(), siteName: site.siteName, siteFavIcon: site.siteFavIcon)
            newDetails.append(details)
        }
        self.sitesButton = newDetails

    }
    
    
    
    //MARK: Load Free Flow Positions
    private func loadFreeFlowPositions() {
        let settings = settingsRepo.get()
        self.updateXPercent = settings.freeFlowXPercent
        self.updateYPercent = settings.freeFlowYPercent
    }

    

    //MARK: Update Free Flos XY Percent
    func updateFreeFlowXYPercent(_ newXPercent: CGFloat, _ newYPercent: CGFloat, save: Bool = false) {
        updateXPercent = max(0.1, min(0.9, newXPercent))
        updateYPercent = max(0.1, min(0.9, newYPercent))

        if save {
            settingsRepo.update() { settings in
                settings.freeFlowXPercent = updateXPercent
                settings.freeFlowYPercent = updateYPercent
            }
        }
    }

    
}

