//
//  OptionsEditSite-VM.swift
//  qFocus Browser
//
//
//import Foundation
import SwiftUI



@MainActor
final class OptionsEditSiteVM: ObservableObject {
    @Published var tempName: String
    @Published var tempURL: String
    @Published var faviconImage: UIImage?
    @Published var siteToEdit: SitesStorage
    @Published var enableGreasy: Bool
    @Published var enableAdBlocker: Bool
    @Published var requestDesktop: Bool
    @Published var cookieStoreID: UUID?

    var editSite: SitesStorage?
    var isNewSite: Bool
    let sitesRepo: SitesRepo


    
    //MARK: Init
    init(editSite: SitesStorage?, sitesRepo: SitesRepo) {

        self.sitesRepo = sitesRepo
        self.editSite = editSite
        self.isNewSite = editSite == nil
        
        if let site = editSite {
            #if DEBUG
                print("Editing exising site")
            #endif
            self.siteToEdit = site
            self.tempName = site.siteName
            self.tempURL = site.siteURL
            if let faviconData = site.siteFavIcon,
               let image = UIImage(data: faviconData) {
                self.faviconImage = image
            } else {
                self.faviconImage = nil
            }
            self.enableGreasy = site.enableGreasy
            self.enableAdBlocker = site.enableAdBlocker
            self.requestDesktop = site.requestDesktop
            self.cookieStoreID = site.cookieStoreID
        } else {
            #if DEBUG
                print("Adding new site")
            #endif
            let newSite = SitesStorage()
            self.siteToEdit = newSite
            self.tempName = ""
            self.tempURL = "https://"
            self.faviconImage = nil
            self.enableGreasy = true
            self.enableAdBlocker = true
            self.requestDesktop = false
            self.cookieStoreID = UUID()
        }
        
    }
    


    //MARK: Fetch FavIcon
    func fetchFavicon(for url: String) {
        guard !url.isEmpty else { return }
        let fqdn = fqdnOnly(from: url)
        guard let iconURL = URL(string: "https://icons.duckduckgo.com/ip3/\(fqdn).ico") else { return }

        URLSession.shared.dataTask(with: iconURL) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.faviconImage = image
            }
        }.resume()
    }

    
    
    //MARK: Save Data
    func saveData() {
        
        fetchFavicon(for: tempURL)

        let existingSites = sitesRepo.getAllSites()
        if tempName.isEmpty {
            if !isNewSite {
                sitesRepo.deleteSite(siteToEdit)
                sitesRepo.reorderSites()
                CombineRepo.shared.updateWebSites.send()

                Collector.shared.save(event: "Site Deleted", parameter: siteToEdit.siteURL)
            }
            return
        }

        if isNewSite {
            if tempURL == "https://" { return }
            sitesRepo.addSite(
                siteOrder: existingSites.count,
                siteName: tempName,
                siteURL: tempURL,
                siteFavIcon: faviconImage?.pngData(),
                enableGreasy: enableGreasy,
                enableAdBlocker: enableAdBlocker,
                requestDesktop: requestDesktop,
                cookieStoreID: UUID()
            )
            CombineRepo.shared.updateWebSites.send()
            Collector.shared.save(event: "Site Added", parameter: tempURL)
            
        } else {
            sitesRepo.editSite(
                site: siteToEdit,
                siteOrder: siteToEdit.siteOrder,
                siteName: tempName,
                siteURL: tempURL,
                siteFavIcon: faviconImage?.pngData() ?? UIImage(systemName: "globe")?.pngData(),
                enableGreasy: enableGreasy,
                enableAdBlocker: enableAdBlocker,
                requestDesktop: requestDesktop,
                cookieStoreID: (siteToEdit.siteURL != tempURL ? UUID() : siteToEdit.cookieStoreID)
            )
            CombineRepo.shared.updateWebSites.send()
            Collector.shared.save(event: "Site Updated", parameter: tempURL)

        }

    }
}

