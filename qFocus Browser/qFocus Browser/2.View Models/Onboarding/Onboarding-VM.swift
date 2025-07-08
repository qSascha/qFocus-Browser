//
//  Onboarding-VM.swift
//  qFocus Browser
//
//
import Foundation
import Photos
import SwiftUI



@MainActor
class OnboardingVM: ObservableObject {
    
    enum PictureAccessLevel: String, Equatable, CaseIterable {
        case unknown
        case full
        case limited
        case denied
        case restricted
    }

    private let settingsRepo: SettingsRepo
    private let greasyRepo: GreasyScriptRepo

    @Published var currentStep: Int = 1
    @Published var isComplete: Bool = false
    @Published var pictureAccessLevel: PictureAccessLevel = .unknown
    let totalSteps: Int = 7

    

    init(settingsRepo: SettingsRepo, greasyRepo: GreasyScriptRepo) {
        self.settingsRepo = settingsRepo
        self.greasyRepo = greasyRepo
    }



    //MARK: Can Proceed
    var canProceed: Bool {
        //TODO: Add custom validation per step here.
        true
    }

    
    
    //MARK: Next Step
    func nextStep() {
        if currentStep < totalSteps {
            currentStep += 1
        }
    }



    //MARK: Previous Step
    func previousStep() {
        if currentStep > 1 {
            currentStep -= 1
        }
    }


    
    //MARK: Complete Onboarding
    func completeOnboarding() {
        print("Onboarding Complete - Step 0 -----------------------------------------")
        settingsRepo.update() { settings in
            settings.onboardingComplete = true;
            settings.freeFlowXPercent = 0.75;
            settings.freeFlowYPercent = 0.85;
            settings.adBlockUpdateFrequency = 3;   // Weekly
            settings.greasyScriptsEnabled = true
        }


        // Insert default GreasyFork Scripts
        greasyRepo.createDefaultGreasyScripts()

        
        // Inform the StartView about this.
        isComplete = true
    }
    
    
    
    //MARK: Request Photo Access
    func requestPhotoAccess() {
        func accessLevel(for status: PHAuthorizationStatus) -> PictureAccessLevel {
            switch status {
            case .notDetermined: return .unknown
            case .authorized: return .full
            case .limited: return .limited
            case .denied: return .denied
            case .restricted: return .denied
            @unknown default: return .unknown
            }
        }

        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        // Update immediately so user sees the current status before action
        pictureAccessLevel = accessLevel(for: status)

        switch status {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] newStatus in
                Task { @MainActor in
                    self?.pictureAccessLevel = accessLevel(for: newStatus)
                }
            }
        case .authorized, .limited, .denied, .restricted:
            // Update access level (even though it should already be current)
            pictureAccessLevel = accessLevel(for: status)
            // Optionally, print or take further action here.
        @unknown default:
            pictureAccessLevel = .unknown
        }
    }

    
}

extension OnboardingVM.PictureAccessLevel {
    var localizedString: String {
        switch self {
        case .unknown: return "Unknown"
        case .full: return "Full"
        case .limited: return "Limited"
        case .denied: return "Denied"
        case .restricted: return "Restricted"
        }
    }
}
