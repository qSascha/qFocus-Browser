//
//  OptionsGreasyEdit-VM.swift
//  qFocus Browser
//
//
//import FactoryKit
import SwiftUI



@MainActor
public final class OptionsGreasyEditVM: ObservableObject {
    @Published var scriptToEdit: GreasyScriptStorage
    @Published var scriptName: String
    @Published var coreSite: String
    @Published var scriptEnabled: Bool
    @Published var scriptLicense: String
    @Published var scriptExplanation: String
    @Published var siteURL: String
    @Published var scriptURL: String
    @Published var defaultScript: Bool
    @Published var siteFavIcon: UIImage?

    var editScript: GreasyScriptStorage??
    var isNewScript: Bool

    var sitesRepo: SitesRepo
    var greasyRepo: GreasyScriptRepo


    @Published var sites: [SitesStorage] = []
    @Published var linkToShow: IdentifiableURL? = nil

    
    
    //MARK: Init
    init (scriptObject: GreasyScriptStorage?, greasyRepo: GreasyScriptRepo, sitesRepo: SitesRepo, newScript: defaultGreasyScriptItem? = nil) {

        self.editScript = scriptObject
        self.isNewScript = scriptObject == nil

        self.greasyRepo = greasyRepo
        self.sitesRepo = sitesRepo

        if let script = scriptObject {
            print("// Editing Script")
            self.scriptToEdit = script
            self.scriptName = script.scriptName
            self.coreSite = script.coreSite
            self.scriptLicense = script.scriptLicense
            self.scriptEnabled = script.scriptEnabled
            self.scriptExplanation = script.scriptExplanation
            self.siteURL = script.siteURL
            self.scriptURL = script.scriptURL
            self.defaultScript = script.defaultScript
            if let faviconData = script.siteFavIcon,
               let image = UIImage(data: faviconData) {
                self.siteFavIcon = image
            } else {
                self.siteFavIcon = nil
            }

        } else {
            print("// Adding Script")
            let newScriptContent = GreasyScriptStorage()
            self.scriptToEdit = newScriptContent
            self.scriptName = newScript!.scriptName
            self.coreSite = newScript!.coreSite
            self.scriptLicense = newScript!.scriptLicense
            self.scriptEnabled = newScript!.scriptEnabled
            self.scriptExplanation = newScript!.scriptExplanation
            self.siteURL = newScript!.siteURL
            self.scriptURL = newScript!.scriptURL
            self.defaultScript = false
            self.siteFavIcon = nil

            fetchFavicon(for: self.coreSite)

        }

        sites = sitesRepo.getAllSites()

        // Maximum length of Script Name = 40 characters
        if self.scriptName.count >= 40 {
            self.scriptName = String(self.scriptName.prefix(40))
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
                self.siteFavIcon = image
            }
        }.resume()
    }


        
    //MARK: Save Data
    func saveData() {

        if scriptName.isEmpty {
            if !isNewScript {
                print("Deleting ----->")
                greasyRepo.deleteCustomScript(scriptToEdit)
                CombineRepo.shared.updateGreasyScripts.send()
            }
            return
        }

        // If the script has no site selected it defaults to "###disabled###"
        let validSiteTags = sites.map { $0.siteURL.replacingOccurrences(of: "https://", with: "").replacingOccurrences(of: "http://", with: "") }
        if !validSiteTags.contains(self.coreSite) {
            self.coreSite = NSLocalizedString("none-disabled", comment: "")
            self.scriptEnabled = false
            print("ScriptEnabled = false")
        } else {
            self.scriptEnabled = true
            print("ScriptEnabled = true")
        }


        
        if isNewScript {
            print("Adding ----->")
            greasyRepo.addCustomScript(
                scriptName: scriptName,
                coreSite: coreSite,
                scriptEnabled: scriptEnabled,
                scriptExplanation: scriptExplanation,
                siteURL: siteURL,
                scriptURL: scriptURL,
                siteFavIcon: siteFavIcon?.pngData()
            )
            CombineRepo.shared.updateGreasyScripts.send()
            Collector.shared.save(event: "GreasyEdit-added", parameter: scriptURL)

        } else {
            print("Edditing ----->")
            greasyRepo.editCustomScript(
                script: scriptToEdit,
                scriptName: scriptName,
                coreSite: coreSite,
                scriptEnabled: scriptEnabled,
                scriptExplanation: scriptExplanation,
                siteURL: siteURL,
                scriptURL: scriptURL,
                siteFavIcon: siteFavIcon?.pngData()
            )
            CombineRepo.shared.updateGreasyScripts.send()
            Collector.shared.save(event: "GreasyEdit-edited", parameter: scriptURL)

        }



    }
    
    
}

