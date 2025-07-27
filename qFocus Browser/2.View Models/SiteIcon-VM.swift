//
//  SiteIcon-VM.swift
//  qFocus Browser
//
//
import SwiftUI


@MainActor
final class SiteIconVM: ObservableObject {
    @Published var favIcon: UIImage
    @Published var scriptEnabled: Bool = false
    
    let scriptsRepo: GreasyScriptRepo
    let sitesRepo: SitesRepo
    let script: GreasyScriptStorage
    
    
    
    //MARK: Init
    init(script: GreasyScriptStorage, scriptsRepo: GreasyScriptRepo, sitesRepo: SitesRepo) {
        
        self.sitesRepo = sitesRepo
        self.scriptsRepo = scriptsRepo
        self.script = script
            
        if let iconData = script.siteFavIcon,
           let image = UIImage(data: iconData) {
            self.favIcon = image
            print("Successfully loaded FavIcon for: \(script.coreSite)")
        } else {
            self.favIcon = generateBlueSystemImage(named: "globe")!
            Task {
                print("Fetching FavIcon for: \(script.coreSite)")
                await fetchFavicon(for: script)
            }
        }

        
        let exists = sitesRepo.getAllSites().contains(where: { $0.siteURL.replacingOccurrences(of: "https://", with: "") == script.coreSite })
        self.scriptEnabled = exists
        print("--------- coreSite: \(script.coreSite),  Enabled: \(exists)")

    }


    //MARK: Fetch Favicon
    func fetchFavicon(for: GreasyScriptStorage) async {
        let url = script.coreSite
        guard !url.isEmpty else { return }
        let fqdn = fqdnOnly(from: url)
        guard let iconURL = URL(string: "https://icons.duckduckgo.com/ip3/\(fqdn).ico") else { return }

        URLSession.shared.dataTask(with: iconURL) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self.favIcon = image

                let exists = self.sitesRepo.getAllSites().contains(where: { $0.siteURL.replacingOccurrences(of: "https://", with: "") == self.script.coreSite })
                self.script.scriptEnabled = exists
                self.scriptEnabled = exists
                print("coreSite: \(self.script.coreSite), Enabled: \(exists)")

                self.scriptsRepo.editCustomScript(
                    type: .builtin,
                    script: self.script,
                    scriptName: self.script.scriptName,
                    coreSite: self.script.coreSite,
                    scriptEnabled: self.script.scriptEnabled,
                    scriptExplanation: self.script.scriptExplanation,
                    siteURL: self.script.siteURL,
                    scriptURL: self.script.scriptURL,
                    siteFavIcon: image.pngData()
                )
            }

        }.resume()

    }
    
    
}

