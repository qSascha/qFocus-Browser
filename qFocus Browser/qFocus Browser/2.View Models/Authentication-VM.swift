//
//  Authentication-VM.swift
//  qFocus Browser
//
//

import Foundation



@MainActor
final class AuthenticationVM: ObservableObject {
    @Published var isAuthenticating = true
    
    func attemptFaceID(completion: @escaping (Bool) -> Void) {
        AuthenticationManager.shared.authenticateWithBiometrics { success, error in
            DispatchQueue.main.async {
                self.isAuthenticating = false
                completion(success)
            }
        }
    }

}
