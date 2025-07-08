//
//  OptionsGreasy-VM.swift
//  qFocus Browser
//
//
//import FactoryKit
import SwiftUI
import Combine



@MainActor
final class GreasySettingsVM: ObservableObject {
    let sitesRepo: SitesRepo
    let settingsRepo: SettingsRepo
    let greasyRepo: GreasyScriptRepo

    @Published var builtinScripts: [GreasyScriptStorage] = []
    @Published var customScripts: [GreasyScriptStorage] = []

    private var cancellables = Set<AnyCancellable>()

    
    
    var toggleGreasy: Bool {
        get { self.settingsRepo.get().greasyScriptsEnabled }
        set { self.settingsRepo.update { settings in
                settings.greasyScriptsEnabled = newValue
            }
            objectWillChange.send()
        }
    }
 

    
    //MARK: Init
    init (sitesRepo: SitesRepo, settingsRepo: SettingsRepo, greasyRepo: GreasyScriptRepo) {
        self.sitesRepo = sitesRepo
        self.settingsRepo = settingsRepo
        self.greasyRepo = greasyRepo
        
        builtinScripts = greasyRepo.getAllScripts(type: .builtin)
        customScripts = greasyRepo.getAllScripts(type: .custom)


        // Update Web Views - triggered by adding or removing a site
        CombineRepo.shared.updateGreasyScripts
            .sink { [weak self] _ in
                self?.refreshCustomScripts()
            } .store(in: &cancellables)

    }

    

    //MARK: Refresch Custom Scripts
    func refreshCustomScripts() {
        customScripts = greasyRepo.getAllScripts(type: .custom)
    }
    
    
    
    
    
    
    
}

