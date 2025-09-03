//
//  FirstSite-VM.swift
//  qFocus Browser
//
//
import Foundation
import SwiftUI



@MainActor
class FirstSiteVM: ObservableObject {
    @Published var siteName: String = ""
    @Published var siteURL: String = ""
    @Published var faviconImage: UIImage?
    @Published var isValid: Bool = false
    
    private var debounceTimer: Timer?
    private let sitesRepo: SitesRepo
    private var existingSite: SitesStorage?
    private var lastSiteURL: String?

    
    //MARK: Init
    init(sitesRepo: SitesRepo) {
        self.sitesRepo = sitesRepo
    }
    
    
    
    //MARK:  onNameChange
    func onNameChange(_ newValue: String) {
        self.siteURL = "https://\(newValue.lowercased()).com"
        self.isValid = !newValue.isEmpty
    }

    
    
    //MARK: onURLChange
    func onURLChange(_ newValue: String) {
        self.updateFavicon(for: newValue)
    }
    

    
    //MARK: updateFavicon
    func updateFavicon(for url: String) {
        guard !url.isEmpty else { return }

        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { [weak self] _ in
            guard let self = self else { return }

            let fqdn = url.replacingOccurrences(of: "https://", with: "")
                .replacingOccurrences(of: "http://", with: "")

            guard let iconURL = URL(string: "https://icons.duckduckgo.com/ip3/\(fqdn).ico") else { return }

            URLSession.shared.dataTask(with: iconURL) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.faviconImage = image
                    }
                }
            }.resume()
        }
    }

    
    //MARK: loadFirstSite
    func loadFirstSiteIfAvailable() {
        let allSites = sitesRepo.getAllSites()
        if let first = allSites.first {
            existingSite = first
            siteName = first.siteName
            siteURL = first.siteURL
            faviconImage = first.siteFavIcon.flatMap { UIImage(data: $0) }
            isValid = !siteName.isEmpty
            // Add a placeholder favicon image only if there's not already a real one
            #if DEBUG
            print("Site loaded: \(siteName)")
            #endif
        }
        if faviconImage == nil {
            faviconImage = generateBlueSystemImage(named: "globe")
        }
    }

    
    
    //MARK: saveSite
    func saveSite() {
        
        updateFavicon(for: siteURL)

        if let existing = existingSite {
            sitesRepo.editSite(
                site: existing,
                siteOrder: existing.siteOrder,
                siteName: siteName,
                siteURL: siteURL,
                siteFavIcon: faviconImage?.pngData(),
                enableGreasy: existing.enableGreasy,
                enableAdBlocker: existing.enableAdBlocker,
                requestDesktop: existing.requestDesktop,
                cookieStoreID: existing.cookieStoreID
            )
            #if DEBUG
            print("Site edited: \(siteName)")
            #endif
        } else {
            sitesRepo.addSite(
                siteOrder: 1,
                siteName: siteName,
                siteURL: siteURL,
                siteFavIcon: faviconImage?.pngData(),
                enableGreasy: true,
                enableAdBlocker: true,
                requestDesktop: false,
                cookieStoreID: UUID()
            )
        }
    }
    
    
    
}
