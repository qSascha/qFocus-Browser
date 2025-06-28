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
    
    
    var faceIDVM: Factory<FaceIDVM> {
        Factory(self) {
            MainActor.assumeIsolated {
                FaceIDVM(
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
                    settingsRepo: self.settingsRepo()
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
                    adBlockFilterRepo: self.adBlockFilterRepo()
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


    var adBlockFilterRepo: Factory<AdBlockFilterRepo> {
        Factory(self) {
            AdBlockFilterRepo(context: self.managedObjectContext())
        }.scope(.shared)
    }


}



//MARK: Core Data
extension Container {
    
    var persistentContainer: Factory<NSPersistentContainer> {
        Factory(self) {
            let container = NSPersistentContainer(name: "qFocusModel")
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


