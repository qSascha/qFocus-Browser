//
//  Options-VM.swift
//  qFocus Browser
//
//
import SwiftUI
import Photos
import Combine
@preconcurrency import LocalAuthentication



@MainActor
final class OptionsVM: ObservableObject {
    let sitesRepo: SitesRepo
    let settingsRepo: SettingsRepo
    let adBlockFilterRepo: AdBlockFilterRepo
    let settings: SettingsStorage

    @Published var sites: [SitesStorage] = []
    @Published var externalURL: IdentifiableURL? = nil
    @Published var alPhotoLibraryImage: String = ""
    @Published var alPhotoLibraryText: LocalizedStringKey = ""
    @Published var alPhotoLibraryColor: Color = .primary
    @Published var alPhotoLibraryLink: Bool = false

    @Published var biometryType: LABiometryType = .none
    @Published var biometrySFSymbol: String = ""
    @Published var biometryText: String = ""

    // Countdown state
    @Published var disableEBCountdownActive: Bool = false
    @Published var disableEBcountdownRemaining: Int = 0
    @Published var disableEBCountdownText: String = "3:00"
    private let disableEBDurationSeconds: Int = 180

    let iconSize: CGFloat = 30
    let maxSites: Int = 6
    
    private var cancellables = Set<AnyCancellable>()
    private var disableEBCancellable: AnyCancellable?
    
    
    var enabledFilterCount: Int {
        adBlockFilterRepo.getAllEnabled().count
    }
    
    // Optional helper if you still want a computed formatted string
    var disableEBCountdownFormatted: String {
        let remaining = max(0, disableEBcountdownRemaining)
        let minutes = remaining / 60
        let seconds = remaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }


    //MARK: Init
    init(sitesRepo: SitesRepo, settingsRepo: SettingsRepo, adBlockFilterRepo: AdBlockFilterRepo) {
        self.sitesRepo = sitesRepo
        self.settingsRepo = settingsRepo
        self.adBlockFilterRepo = adBlockFilterRepo
        
        self.settings = settingsRepo.get()
        
        refreshSites()

        
        
        biometryType = AuthenticationManager.shared.currentBiometryType()
//        refreshBiometryType()

        switch biometryType {
        case .faceID:
            biometrySFSymbol = "faceid"
            biometryText = NSLocalizedString("options.settings.authTypeFaceID", comment: "")
        case .touchID:
            biometrySFSymbol = "touchid"
            biometryText = NSLocalizedString("options.settings.authTypeTouchID", comment: "")
        case .opticID:
            biometrySFSymbol = "eye.circle"
            biometryText = NSLocalizedString("options.settings.authTypeOpticID", comment: "")
        default:
            biometrySFSymbol = "lock"
            biometryText = NSLocalizedString("options.settings.authTypeGeneral", comment: "")
        }

        
        
        
        
        
        
        
        
        
        // Publish current Photos authorization to show an initial value in the UI
        photoLibraryPublishStatus()

        // Update Web Views - triggered by adding or removing a site
        CombineRepo.shared.updateWebSites
            .sink { [weak self] _ in
                self?.refreshSites()
            } .store(in: &cancellables)

    }
    
    

    //MARK: FaceID Enabled
    var faceIDEnabled: Bool {
        get { settings.faceIDEnabled }
        set {
            settingsRepo.update { settings in
                settings.faceIDEnabled = newValue
                Collector.shared.save(event: "Setting", parameter: "FaceID: \(newValue)")
            }
        }
    }
    
    

    //MARK:PhotoLibrary
    func photoLibraryRequestAccess() {

        // Check the current access level
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)

        switch status {
        case .notDetermined:
            // If it is not yet set then show system UI
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] _ in
                Task { @MainActor in
                    self?.photoLibraryPublishStatus()
                }
            }
        case .authorized, .limited, .denied, .restricted:
            // If it has been set then send user to Settings app to change it
            openAppSettings()
        @unknown default:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] _ in
                Task { @MainActor in
                    self?.photoLibraryPublishStatus()
                }
            }
        }

    }

    
    
    //MARK: Photo Library Publish Status
    func photoLibraryPublishStatus() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized:
            self.alPhotoLibraryImage = "checkmark.seal.fill"
            self.alPhotoLibraryText = LocalizedStringKey("PhotoLibrary-Allowed")
            self.alPhotoLibraryColor = .green
            self.alPhotoLibraryLink = true

        case .limited:
            self.alPhotoLibraryImage = "checkmark.circle.trianglebadge.exclamationmark.fill"
            self.alPhotoLibraryText = LocalizedStringKey("PhotoLibrary-Limited")
            self.alPhotoLibraryColor = .orange
            self.alPhotoLibraryLink = true

        case .denied, .restricted:
            self.alPhotoLibraryImage = "exclamationmark.shield.fill"
            self.alPhotoLibraryText = LocalizedStringKey("PhotoLibrary-Denied")
            self.alPhotoLibraryColor = .red
            self.alPhotoLibraryLink = true

        case .notDetermined:
            self.alPhotoLibraryImage = "questionmark.square.fill"
            self.alPhotoLibraryText = LocalizedStringKey("PhotoLibrary-Not determined")
            self.alPhotoLibraryColor = .gray
            self.alPhotoLibraryLink = false

        @unknown default:
            self.alPhotoLibraryImage = "questionmark.square.fill"
            self.alPhotoLibraryText = "PhotoLibrary-Unknown"
            self.alPhotoLibraryColor = .gray
        }
    }

    
    
    //MARK: Disable External Browser 
    func disableExternalBrowser() {
        // If a countdown is already active, stop it and finalize as if it reached zero.
        if disableEBCountdownActive {
            disableEBCancellable?.cancel()
            disableEBCancellable = nil
            disableEBcountdownRemaining = 0
            disableEBCountdownText = formattedTime(from: 0)
            disableEBCountdownActive = false
            // Broadcast: external browser enabled again
            CombineRepo.shared.externalBrowserDisabled.send(false)
            Collector.shared.save(event: "Setting", parameter: "DisableExternalBrowser-Countdown: finishedEarly")
            return
        }

        // Otherwise start 2-minute countdown
        startCountdown()
        Collector.shared.save(event: "Setting", parameter: "DisableExternalBrowser-Countdown: \(disableEBDurationSeconds)")
    }



    //MARK: Start Countdown (Combine Timer)
    func startCountdown() {
        // Cancel any existing countdown
        disableEBCancellable?.cancel()
        disableEBCancellable = nil
        
        disableEBcountdownRemaining = disableEBDurationSeconds
        disableEBCountdownText = formattedTime(from: disableEBcountdownRemaining)
        disableEBCountdownActive = disableEBcountdownRemaining > 0

        guard disableEBcountdownRemaining > 0 else {
            disableEBCountdownActive = false
            CombineRepo.shared.externalBrowserDisabled.send(false)
            return
        }

        // Broadcast: external browser disabled while countdown runs
        CombineRepo.shared.externalBrowserDisabled.send(true)

        disableEBCancellable = Timer
            .publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                if self.disableEBcountdownRemaining > 0 {
                    self.disableEBcountdownRemaining -= 1
                    self.disableEBCountdownText = self.formattedTime(from: self.disableEBcountdownRemaining)
                }
                if self.disableEBcountdownRemaining <= 0 {
                    self.disableEBCountdownActive = false
                    // Broadcast: external browser enabled after countdown finishes
                    CombineRepo.shared.externalBrowserDisabled.send(false)
                    self.disableEBCancellable?.cancel()
                    self.disableEBCancellable = nil
                }
            }
    }

    private func formattedTime(from seconds: Int) -> String {
        let s = max(0, seconds)
        let m = s / 60
        let r = s % 60
        return String(format: "%d:%02d", m, r)
    }

    
    //MARK: AdBlock Update Frequency
    var adBlockUpdateFrequency: Int16 {
        get { settings.adBlockUpdateFrequency }
        set {
            settingsRepo.update { settings in
                settings.adBlockUpdateFrequency = newValue
                Collector.shared.save(event: "Setting", parameter: "AdBlock-Update-Frequency: \(newValue)")
            }
        }
    }
    
    
    
    //MARK: AdBlock Enabled
    var isAdBlockEnabled: Bool {
        return settings.adBlockEnabled
    }
    

    
    //MARK: Refresh Sites
    func refreshSites() {
        sites = sitesRepo.getAllSites().sorted(by: { $0.siteOrder < $1.siteOrder })
    }
    
    

    
    //MARK: Can Add Site
    func canAddSite() -> Bool {
        return sites.count < maxSites
    }
    
    

    //MARK: Remaining Slots
    func remainingSlots() -> Int {
        return maxSites - sites.count
    }
    


    //MARK: Persist Site Order
    func persistSiteOrder() {
        sitesRepo.persistSiteOrder(sites: sites)
    }



    //MARK: Save
    func save() {
        settingsRepo.save()
    }

}

