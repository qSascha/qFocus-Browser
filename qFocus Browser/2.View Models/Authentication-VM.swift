//
//  Authentication-VM.swift
//  qFocus Browser
//
//
@preconcurrency import LocalAuthentication

import Foundation



@MainActor
final class AuthenticationVM: ObservableObject {
    @Published var isAuthenticating = true
    @Published var biometryType: LABiometryType = .none
    @Published var authEnabled: Bool
    @Published var biometryHeader: String = ""
    @Published var biometryText: String = ""
    @Published var biometrySFSymbol: String = ""
    @Published var biometryTextEnabled: String = ""
    @Published var biometryTextDisabled: String = ""
    @Published var biometryTextButton: String = ""

    private let settingsRepo: SettingsRepo

    
    init(settingsRepo: SettingsRepo) {
        self.settingsRepo = settingsRepo
        self.authEnabled = settingsRepo.get().faceIDEnabled
        refreshBiometryType()

        switch biometryType {
        case .faceID:
            biometrySFSymbol = "faceid"
            biometryHeader = NSLocalizedString("onboarding.030faceid.header", comment: "")
            biometryText = NSLocalizedString("onboarding.030faceid.text", comment: "")
            biometryTextEnabled = NSLocalizedString("onboarding.030faceid.enabled", comment: "")
            biometryTextDisabled = NSLocalizedString("onboarding.030faceid.disabled", comment: "")
            biometryTextButton = NSLocalizedString("onboarding.030faceid.button", comment: "")
        case .touchID:
            biometrySFSymbol = "touchid"
            biometryHeader = NSLocalizedString("onboarding.030touchid.header", comment: "")
            biometryText = NSLocalizedString("onboarding.030touchid.text", comment: "")
            biometryTextEnabled = NSLocalizedString("onboarding.030touchid.enabled", comment: "")
            biometryTextDisabled = NSLocalizedString("onboarding.030touchid.disabled", comment: "")
            biometryTextButton = NSLocalizedString("onboarding.030touchid.button", comment: "")
        case .opticID:
            biometrySFSymbol = "eye.circle"
            biometryHeader = NSLocalizedString("onboarding.030opticid.header", comment: "")
            biometryText = NSLocalizedString("onboarding.030opticid.text", comment: "")
            biometryTextEnabled = NSLocalizedString("onboarding.030opticid.enabled", comment: "")
            biometryTextDisabled = NSLocalizedString("onboarding.030opticid.disabled", comment: "")
            biometryTextButton = NSLocalizedString("onboarding.030opticid.button", comment: "")
        default:
            biometrySFSymbol = "lock"
            biometryHeader = NSLocalizedString("onboarding.030biometrics.header", comment: "")
            biometryText = NSLocalizedString("onboarding.030biometrics.text", comment: "")
            biometryTextEnabled = NSLocalizedString("onboarding.030biometrics.enabled", comment: "")
            biometryTextDisabled = NSLocalizedString("onboarding.030biometrics.disabled", comment: "")
            biometryTextButton = NSLocalizedString("onboarding.030biometrics.button", comment: "")
        }

    }

    
    
    func refreshBiometryType() {
        biometryType = AuthenticationManager.shared.currentBiometryType()
    }
    
    func attemptFaceID(completion: @Sendable @escaping (Bool) -> Void) {
        AuthenticationManager.shared.authenticateWithBiometrics { [weak self] success, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isAuthenticating = false
                completion(success)
            }
        }
    }
    
    // Enable FaceID/biometrics for app lock
    func enableFaceID() {
        let reason = NSLocalizedString("onboarding.030faceid.localizedReason", comment: "")
        AuthenticationManager.shared.authenticateWithBiometrics(reason: reason) { [weak self] success, _ in
            guard let self = self else { return }
            Task { @MainActor in
                self.settingsRepo.update { settings in
                    settings.faceIDEnabled = success
                }
                self.authEnabled = success
#if DEBUG
                print(success ? "✅ FaceID has been enabled successfully." : "❌ FaceID could not be enabled.")
#endif
            }
        }
    }
    
}



@MainActor
final class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    
    private init() {}

    func currentBiometryType() -> LABiometryType {
        let context = LAContext()
        var authError: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            return context.biometryType
        } else {
            return .none
        }
    }

    func authenticateWithBiometrics(reason: String = "Unlock qFocus Browser", completion: @Sendable @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        var authError: NSError?
        
        // Check if biometric authentication is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [completion] success, evaluateError in
                DispatchQueue.main.async {
                    completion(success, evaluateError)
                }
            }
        } else {
            DispatchQueue.main.async { [completion] in
                completion(false, authError)
            }
        }
    }
}

