//
//  Main-VM.swift
//  qFocus Browser
//
//
import Foundation
import WebKit
import Combine



@MainActor
final class MainVM: ObservableObject {
    @Published var sitesRepo: SitesRepo
    @Published var sitesDetails: [SitesDetails] = []
    @Published var selectedWebViewID: UUID?
    @Published var externalURL: IdentifiableURL? = nil
    @Published var showPrivacy: Bool = false

    private var cancellables = Set<AnyCancellable>()
    


    //MARK: Init
    init(sitesRepo: SitesRepo) {
        self.sitesRepo = sitesRepo

        // Update Web Views - triggered by various option changes
        CombineRepo.shared.updateWebSites
             .sink { [weak self] _ in
                 Task { await self?.loadAllWebViews() }
             } .store(in: &cancellables)


        // Select Web Views - triggered by Menu button in NavigationBar and NavigationFlow
        CombineRepo.shared.selectWebView
             .sink { [weak self] index in
                 self?.selectWebView(at: index)
             } .store(in: &cancellables)


        // Set externalURL to open External Browser sheet
        CombineRepo.shared.triggerExternalBrowser
            .sink { [weak self] url in
                self?.externalURL = IdentifiableURL(url: url)
            }
            .store(in: &cancellables)


        // Set showPrivacy = false to dismiss Resuming View
        CombineRepo.shared.dismissResuming
            .sink { [weak self] _ in
                self?.showPrivacy = false
            }
            .store(in: &cancellables)


        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                CombineRepo.shared.lockApp.send()
            }
        }


        NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { notification in
            Task { @MainActor in
                print("------ Showing Privacy -----")
                self.showPrivacy = true
            }
        }
        


// Test only
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                print("----- Unlocking App -----")
 //               self.onResuming()
            }
        }
        
        NotificationCenter.default.addObserver(
//            forName: UIApplication.willEnterForegroundNotification,
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                print("----- Hiding Privacy -----")
//                self.onResuming()
            }
        }










    }

    
    
    //MARK: deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    
    
    //MARK: Load All WebViews
    func loadAllWebViews() async {
        // Clear all current WebViews
        self.sitesDetails.removeAll()
        
        // Fetch the latest site configurations
        let sites = sitesRepo.getAllSites()
        var newDetails: [SitesDetails] = []
        
        for site in sites {
            let webViewVM = AppDIContainer.shared.webViewVM()
            await webViewVM.initializeWebView(assignViewID: site.cookieStoreID)

            let details = SitesDetails(id: site.cookieStoreID, viewModel: webViewVM)

            newDetails.append(details)
        }
        
        self.sitesDetails = newDetails
        
        // Select first site by default if available
        if let first = newDetails.first {
            selectedWebViewID = first.id
        }

    }
    
    
    //MARK: Get All Sites
    func getAllSites() -> [SitesStorage] {
        return sitesRepo.getAllSites(order: .descending)
    }
    
    
    //MARK: Select WebView
    func selectWebView(at index: Int) {
        // Switch active WebView by index
        guard index >= 0, index < sitesDetails.count else { return }
        selectedWebViewID = sitesDetails[index].id
    }
    
    
    
}

