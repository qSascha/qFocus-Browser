//
//  Authentication-UC.swift
//  qFocus Browser
//
//

import LocalAuthentication
import Foundation



@MainActor
class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    
    private init() {}

    func authenticateWithBiometrics(reason: String = "Unlock qFocus Browser", completion: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        var authError: NSError?
        
        // Check if biometric authentication is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, evaluateError in
                DispatchQueue.main.async {
                    completion(success, evaluateError)
                }
            }
        } else {
            DispatchQueue.main.async {
                completion(false, authError)
            }
        }
    }
}

