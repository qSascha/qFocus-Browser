//
//  hHelpers.swift
//  qFocus Browser
//
//  Created by Sascha on 2024-12-08.
//

import Foundation
import SwiftUI
import LocalAuthentication


#if os(macOS)
    import AppKit
#else
    import UIKit
#endif






class GlobalVariables: ObservableObject {
    
    @Published var currentTab: Int = 0
    @Published var tempSiteName: String = ""
    @Published var tempSiteURL: String = ""
    @Published var tempSiteFavIcon: Data? = nil
    @Published var showOptionsView: Bool = false
    @Published var showShareSheet: Bool = false
    @Published var faceIDEnabled: Bool = false
    @Published var menuIconSize: CGFloat = 32
    @Published var appVersion: String = "25.02"
    @Published var greaseForkList: [greasyScriptItem] = createGreasyScriptsList() {
        didSet { objectWillChange.send() }
    }
    @Published var adBlockList: [AdBlockFilterItem] = createAdBlockFilterList() {
        didSet { objectWillChange.send() }
    }

}




// MARK: Face ID Authenticator
class AuthenticationManager: ObservableObject {
    @Published var isUnlocked = false
    
    func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                 localizedReason: "Unlock qFocus Browser") { success, error in
                DispatchQueue.main.async {
                    self.isUnlocked = success
                }
            }
        }
    }
}





//MARK: Language information
func languageIsRightToLeft() -> Bool {
    return Locale.current.language.characterDirection == .rightToLeft
}

func deviceLanguage() -> String {
    return Locale.current.language.languageCode?.identifier ?? "en"
}







// TODO: Really needed? Can't we use the "host" value, e.g. in the MenuButton view?
func getDomainCore(_ host: String) -> String {
    let components = host.lowercased().split(separator: ".")
    guard components.count >= 2 else { return host.lowercased() }
    let mainDomain = components.suffix(2).joined(separator: ".")
    return mainDomain
}










#if os(iOS)
    
func isiPad() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
}

#endif




