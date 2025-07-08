//
//  ResumeVM.swift
//  qFocus Browser
//
//
import Foundation
import SwiftUI
import Combine



@MainActor
class ResumeVM: ObservableObject {
    private let settingsRepo: SettingsRepo

    @Published var showAuthenticationSheet: Bool = false
    @Published var showAuthenticationFailedSheet: Bool = false
    @Published var isFinished: Bool = false
    
    private(set) var faceIDEnabled: Bool = false



    //MARK: init
    init( settingsRepo: SettingsRepo) {
        self.settingsRepo = settingsRepo
        
    }
 
    

    //MARK: Start
    func start() {
        self.faceIDEnabled = settingsRepo.get().faceIDEnabled
        self.isFinished = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.faceIDEnabled {
                // Open authentication sheet
                self.showAuthenticationSheet = true
            } else {
                // Directly proceed after loading
                self.authenticationSucceeded()
            }
        }
    }
    
    
    
    func authenticationSucceeded() {
        showAuthenticationSheet = false
        showAuthenticationFailedSheet = false

        isFinished = true
        CombineRepo.shared.dismissResuming.send()
        CombineRepo.shared.updateNavigationBar.send(false)
    }
    
    
    
    func authenticationFailed() {
        showAuthenticationSheet = false
        showAuthenticationFailedSheet = true
    }
    
    
    
    func retryAuthentication() {
        showAuthenticationFailedSheet = false
        showAuthenticationSheet = true
    }
    
}

