//
//  DI-Container.swift
//  qFocus Browser
//
//
import CoreData
import FactoryKit



enum AppDIContainer {
    static let shared = Container()
}





//MARK: ViewModels
extension Container {
    
    var adBlockSelectVM: Factory<AdBlockSelectVM> {
        Factory(self) {
            MainActor.assumeIsolated {
                AdBlockSelectVM(
                    adBlockFilterRepo: self.adBlockFilterRepo()
                )
            }
        }.scope(.shared)
    }
    
    
    var adBlockSettingsVM: Factory<iOSAdBlockSettingsVM> {
        Factory(self) {
            MainActor.assumeIsolated {
                iOSAdBlockSettingsVM(
                    adBlockUC: self.adBlockUC(),
                    sitesRepo: self.sitesRepo(),
                    settingsRepo: self.settingsRepo(),
                    adBlockFilterRepo: self.adBlockFilterRepo()
                )
            }
        }.scope(.shared)
    }
    
    
    var authenticationVM: Factory<AuthenticationVM> {
        Factory(self) {
            MainActor.assumeIsolated {
                AuthenticationVM(
                    settingsRepo: self.settingsRepo()
                )
            }
        }.scope(.shared)
    }
    
    
    var firstSiteVM: Factory<FirstSiteVM> {
        Factory(self) {
            MainActor.assumeIsolated {
                FirstSiteVM(
                    sitesRepo: self.sitesRepo()
                )
            }
        }.scope(.shared)
    }

    
    var greasySettingsVM: Factory<GreasySettingsVM> {
        Factory(self) {
            MainActor.assumeIsolated {
                GreasySettingsVM(
                    sitesRepo: self.sitesRepo(),
                    settingsRepo: self.settingsRepo(),
                    greasyRepo: self.greasyRepo()
                )
            }
        }.scope(.shared)
    }

    
    var loadingVM: Factory<LoadingVM> {
        Factory(self) {
            MainActor.assumeIsolated {
                LoadingVM(
                    settingsRepo: self.settingsRepo()
                )
            }
        }.scope(.shared)
    }
    
    
    var mainVM: Factory<MainVM> {
        Factory(self) {
            MainActor.assumeIsolated {
                MainVM(
                    sitesRepo: self.sitesRepo()
                )
            }
        }.scope(.shared)
    }
    
    
    var navigationVM: Factory<NavigationVM> {
        Factory(self) {
            MainActor.assumeIsolated {
                NavigationVM(
                    sitesRepo: self.sitesRepo(),
                    settingsRepo: self.settingsRepo()
                )
            }
        }.scope(.shared)
    }
    
    
    var onboardingVM: Factory<OnboardingVM> {
        Factory(self) {
            MainActor.assumeIsolated {
                OnboardingVM(
                    settingsRepo: self.settingsRepo(),
                    greasyRepo: self.greasyRepo()
                )
            }
        }.scope(.shared)
    }
    
    
    var optionsVM: Factory<OptionsVM> {
        Factory(self) {
            MainActor.assumeIsolated {
                OptionsVM(
                    sitesRepo: self.sitesRepo(),
                    settingsRepo: self.settingsRepo(),
                    adBlockFilterRepo: self.adBlockFilterRepo(),
                )
            }
        }.scope(.shared)
    }
    

    
    var resumeVM: Factory<ResumeVM> {
        Factory(self) {
            MainActor.assumeIsolated {
                ResumeVM(
                    settingsRepo: self.settingsRepo()
                )
            }
        }.scope(.shared)
    }
    
    
    var startVM: Factory<StartVM> {
        Factory(self) {
            MainActor.assumeIsolated {
                StartVM(
                    adBlockRepo: self.adBlockFilterRepo(),
                    settingsRepo: self.settingsRepo(),
                    sitesRepo: self.sitesRepo()
                )
            }
        }.scope(.shared)
    }
    
    
    var webViewVM: Factory<WebViewVM> {
        Factory(self) {
            MainActor.assumeIsolated {
                WebViewVM(
                    adBlockRepo: self.adBlockFilterRepo(),
                    settingsRepo: self.settingsRepo(),
                    sitesRepo: self.sitesRepo(),
                    greasyScriptUC: self.greasyScriptUC()
                )
            }
        }.scope(.unique)
    }
 

}
    
    

//MARK: Use Cases
extension Container {
    
    var iOSAdBlockSettVM: Factory<iOSAdBlockSettingsVM> {
        Factory(self) {
            MainActor.assumeIsolated {
                iOSAdBlockSettingsVM(
                    adBlockUC: self.adBlockUC(),
                    sitesRepo: self.sitesRepo(),
                    settingsRepo: self.settingsRepo(),
                    adBlockFilterRepo: self.adBlockFilterRepo(),
                )
            }
        }.scope(.shared)
    }
    
    
    var adBlockUC: Factory<AdBlockFilterUC> {
        Factory(self) {
            MainActor.assumeIsolated {
                AdBlockFilterUC(
                    adBlockRepo: self.adBlockFilterRepo(),
                    settingsRepo: self.settingsRepo(),
                )
            }
        }.scope(.shared)
    }
    

    var greasyScriptUC: Factory<GreasyScriptUC> {
        Factory(self) {
            MainActor.assumeIsolated {
                GreasyScriptUC(
                    greasyRepo: self.greasyRepo(),
                    settingsRepo: self.settingsRepo(),
                )
            }
        }.scope(.shared)
    }

    var adBlockFilterRepo: Factory<AdBlockFilterRepo> {
        Factory(self) {
            AdBlockFilterRepo(context: self.managedObjectContext())
        }.scope(.shared)
    }

    
}
    
    
    
//MARK: Repositories
extension Container {

    var greasyRepo: Factory<GreasyScriptRepo> {
        Factory(self) {
            GreasyScriptRepo(context: self.managedObjectContext())
        }.scope(.shared)
    }


    var settingsRepo: Factory<SettingsRepo> {
        Factory(self) {
            SettingsRepo(context: self.managedObjectContext())
        }.scope(.shared)
    }


    var sitesRepo: Factory<SitesRepo> {
        Factory(self) {
            SitesRepo(context: self.managedObjectContext())
        }.scope(.shared)
    }

}



//MARK: Core Data
extension Container {
    
    var persistentContainer: Factory<NSPersistentContainer> {
        Factory(self) {
            // IMPORTANT: This must match your .xcdatamodeld name (without version suffix)
            let container = NSPersistentContainer(name: "qFocusModel")
            
            // Configure the (single) store description BEFORE loading stores.
            if let description = container.persistentStoreDescriptions.first {
                description.setOption(true as NSNumber, forKey: NSMigratePersistentStoresAutomaticallyOption)
                description.setOption(true as NSNumber, forKey: NSInferMappingModelAutomaticallyOption)
            }
            
            // Now the options above are applied when the store is opened/migrated.
            container.loadPersistentStores { _, error in
                if let error = error {
                    fatalError("Core Data stack init failed: \(error)")
                }
            }
            return container
        }
    }
    
    var managedObjectContext: Factory<NSManagedObjectContext> {
        Factory(self) {
            self.persistentContainer().viewContext
        }
    }
    
}
