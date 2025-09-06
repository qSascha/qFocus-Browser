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
    private var cancellables = Set<AnyCancellable>()
    private var isLocked: Bool = false



    //MARK: init
    init( settingsRepo: SettingsRepo) {

        self.settingsRepo = settingsRepo

        
        // Set isLocked = true to lock app
        CombineRepo.shared.lockApp
            .sink { [weak self] _ in
                print("------ Locking App -----")
                self?.isLocked = true
            }
            .store(in: &cancellables)

        
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                self.onResuming()
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor in
                self.onResuming()
            }
        }

    }
 
    

    //MARK: Start
    func onResuming() {
        if self.isLocked {
            print("----- Unlocking App -----")
            self.faceIDEnabled = settingsRepo.get().faceIDEnabled
            self.isFinished = false
            
            if self.faceIDEnabled {
                // Open authentication sheet
                self.showAuthenticationSheet = true
            } else {
                // Directly proceed after loading
                self.authenticationSucceeded()
            }
        } else {
            // Directly proceed after loading
            print("----- Hiding Privacy -----")
            self.authenticationSucceeded()

        }
    }
    
    
    
    func authenticationSucceeded() {
        showAuthenticationSheet = false
        showAuthenticationFailedSheet = false

        isFinished = true
        isLocked = false
        
        CombineRepo.shared.dismissResuming.send()
//        CombineRepo.shared.updateNavigationBar.send(false)
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

