//
//  Authentication-VM.swift
//  qFocus Browser
//
//

import Foundation



@MainActor
final class AuthenticationVM: ObservableObject {
    @Published var isAuthenticating = true
    
    func attemptFaceID(completion: @Sendable @escaping (Bool) -> Void) {
        AuthenticationManager.shared.authenticateWithBiometrics { [weak self] success, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isAuthenticating = false
                completion(success)
            }
        }
    }
    
}
