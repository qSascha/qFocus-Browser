//
//  LoadingVM.swift
//  qFocus Browser
//
//
import Foundation
import SwiftUI



@MainActor
class LoadingVM: ObservableObject {
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
    func start(platform: AppPlatform) {
        let settings = settingsRepo.get()
        self.faceIDEnabled = settings.faceIDEnabled
        
#if DEBUG
        let timer: Double = 1
#else
        let timer: Double = 3
#endif
        
        DispatchQueue.main.asyncAfter(deadline: .now() + timer) {
            if self.faceIDEnabled {
                // Open authentication sheet
                self.showAuthenticationSheet = true
            } else {
                // Directly proceed after loading
                self.isFinished = true
            }
        }
    }
    
    
    
    func authenticationSucceeded() {
        closeSheets()
        self.isFinished = true
    }
    
    
    
    func authenticationFailed() {
        showAuthenticationSheet = false
        showAuthenticationFailedSheet = true
    }
    
    
    
    func retryAuthentication() {
        showAuthenticationFailedSheet = false
        showAuthenticationSheet = true
    }
    
    
    
    func closeSheets() {
        showAuthenticationSheet = false
        showAuthenticationFailedSheet = false
    }
    
}
