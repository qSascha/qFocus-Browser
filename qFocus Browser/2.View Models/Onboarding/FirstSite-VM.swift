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
    @Published var statusText: String = ""
    
    private var debounceTimer: Timer?
    private let sitesRepo: SitesRepo
    private var existingSite: SitesStorage?
    private var lastSiteURL: String?
    private var reachabilityTask: Task<Void, Never>?
    private var requestID: Int = 0


    
    //MARK: Init
    init(sitesRepo: SitesRepo) {
        self.sitesRepo = sitesRepo
    }
    
    
    
    //MARK:  onNameChange
    func onNameChange(_ newValue: String) {
        self.siteURL = "https://\(newValue.lowercased()).com"
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

    
    
    //MARK: Load Site
    func loadFirstSiteIfAvailable() {
        let allSites = sitesRepo.getAllSites()
        if let first = allSites.first {
            existingSite = first
            siteName = first.siteName
            siteURL = first.siteURL
            faviconImage = first.siteFavIcon.flatMap { UIImage(data: $0) }
        }

        if faviconImage == nil {
            faviconImage = generateBlueSystemImage(named: "globe")
        }
    }

    
    
    //MARK: Save Site
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

    

    //MARK: Check Reachability
    /// Needed to call probeURLReachability, but canceling fast squential triggers, for example when entering the name or URL, as it is triggered on every keystroke.
    func checkReachabilityAndUpdate(_ url: String, update: @escaping (Bool) -> Void) {
        requestID += 1
        let currentID = requestID
        reachabilityTask?.cancel()
        reachabilityTask = Task { @MainActor in
            // Debounce
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard !Task.isCancelled else { return }

            let reachable = await probeURLReachability(url)
            guard currentID == requestID else { return } // ignore stale
            update(reachable)
        }
    }
    
    
    //MARK: Probe URL
    func probeURLReachability(_ urlString: String) async -> Bool {
        // Normalize
        let trimmed = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard var components = URLComponents(string: trimmed) else { return false }
        if components.scheme == nil {
            components.scheme = "https"
        }
        components.host = components.host?.lowercased()
        guard let url = components.url else { return false }

        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 6

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let http = response as? HTTPURLResponse {
                // Consider any HTTP response as reachable
                return (200...499).contains(http.statusCode)
            }
            // Non-HTTP responses are rare; treat as reachable if we got anything
            return true
        } catch {
            // Optional: one retry with small delay to mitigate transient hiccups
            try? await Task.sleep(nanoseconds: 300_000_000)
            do {
                let (_, response) = try await URLSession.shared.data(for: request)
                if let http = response as? HTTPURLResponse {
                    return (100...599).contains(http.statusCode)
                }
                return true
            } catch {
                return false
            }
        }
    }

    
}
