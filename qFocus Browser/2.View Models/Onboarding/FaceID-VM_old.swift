//
//  FaceID-VM.swift
//  qFocus Browser
//
//
/*
import LocalAuthentication
import SwiftUI




@MainActor
final class FaceIDVM: ObservableObject {
    private let settingsRepo: SettingsRepo
    @Published var faceIDEnabled: Bool

    

    init(settingsRepo: SettingsRepo) {
        self.settingsRepo = settingsRepo
        self.faceIDEnabled = settingsRepo.get().faceIDEnabled
    }

    

    //MARK: Enable FaceID
    func enableFaceID() {
        let laContext = LAContext()
        var error: NSError?

        if laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            laContext.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "onboarding.030faceID.localizedReason-old"
            ) { success, _ in
                Task { @MainActor in
                    self.settingsRepo.update { settings in
                        settings.faceIDEnabled = success
                    }
                    self.faceIDEnabled = success

                    print(success
                        ? "✅ FaceID has been enabled successfully."
                        : "❌ FaceID could not be enabled.")
                }
            }
        }
    }
        

}
*/
