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

        }

        self.greasyRepo = greasyRepo
        self.sitesRepo = sitesRepo


        sites = sitesRepo.getAllSites()

        // Maximum length of Script Name = 40 characters
        if self.scriptName.count >= 40 {
            self.scriptName = String(self.scriptName.prefix(40))
        }
        
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
            self.coreSite = "none/disabled"
            self.scriptEnabled = false
            print("ScriptEnabled = false")
        } else {
            self.scriptEnabled = true
            print("ScriptEnabled = truee")
        }


        
        if isNewScript {
            print("Adding ----->")
            greasyRepo.addCustomScript(
                scriptName: scriptName,
                coreSite: coreSite,
                scriptEnabled: scriptEnabled,
                scriptExplanation: scriptExplanation,
                siteURL: siteURL,
                scriptURL: scriptURL
            )
            CombineRepo.shared.updateGreasyScripts.send()

        } else {
            print("Edditing ----->")
            greasyRepo.editCustomScript(
                script: scriptToEdit,
                scriptName: scriptName,
                coreSite: coreSite,
                scriptEnabled: scriptEnabled,
                scriptExplanation: scriptExplanation,
                siteURL: siteURL,
                scriptURL: scriptURL
            )
            CombineRepo.shared.updateGreasyScripts.send()

        }



    }
    
    
}

