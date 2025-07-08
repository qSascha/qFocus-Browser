//
//  Combine-Repo.swift
//  qFocus Browser
//
//
import Foundation
import Combine




// Usage example - Subscribe
/// SwiftUI
///             .onReceive(CombineRepo.shared.updateWebSites) { _ in
///                 viewModel.refreshSites()
///             }
///
///Swift
///
/// import Combine
/// private var cancellables = Set<AnyCancellable>()
///
///    CombineRepo.shared.updateWebSites
///         .sink { [weak self] _ in
///             self?.refreshSites()
///         } .store(in: &cancellables)
///
///
// Usage example - Trigger
/// Swift
///     CombineRepo.shared.updateWebSites.send()
///
///


@MainActor
final class CombineRepo {
    static let shared = CombineRepo()


    /// Observer 1: Update the Navigation view through loading all sites from repo.
    /// Linked to function: loadWebSites
    ///
    /// Observer 2: Update the list of web sites in the Options view.
    /// Linked to function: loadWebSites
    ///
    /// Observer 3: Update MainVM to refresh and reflect on changes to sitesRepo add or removed sites.
    /// Linked to function: loadAllWebViews
    ///
    /// Parameters:
    /// none
    ///
    ///    /// Emits when sites should be reloaded. No parameters.
    let updateWebSites = PassthroughSubject<Void, Never>()

    

    /// Observer 1: MainVM - to select the corresponding web view
    /// Linked to function: selectWebView
    ///
    /// Parameters:
    /// index - this is the indicator to which view to switch to.
    ///
    /// Emits when a specific web view should be selected. Carries the index to select.
    let selectWebView = PassthroughSubject<Int, Never>()

    
    
    /// Observer 1: MainVM - to open External Browser
    /// Linked to function: variable: externalURL
    ///
    /// Parameters:
    /// url - the URL of the site to be opened in the External Browser
    ///
    /// Emits when a specific web view should be selected. Carries the index to select.
    let triggerExternalBrowser = PassthroughSubject<URL, Never>()

    
    
    /// Observer 1: NavigationVM - to minimze the Navigation Bar on scroll
    /// Linked to function: variable: minimizeNavigationBar
    ///
    /// Parameters:
    /// minimize - a bool to inform to minimize or restore the navigation bar
    ///
    /// 1. Emits when the user scrolls a webview up (true) or down (false)
    /// 2. Emits when resuming from background to show the nav bar.
    let updateNavigationBar = PassthroughSubject<Bool, Never>()

    
    
    /// Observer 1: GreasySettingsVM - to list of Greasy Scripts in the list
    /// Linked to function: refreshCustomScripts
    ///
    /// Parameters:
    /// none
    ///
    /// Emits when the individual site has been added, edited or deleted
    let updateGreasyScripts = PassthroughSubject<Void, Never>()

    
    
    /// Observer 1: MainVM - to dismiss the Resuming View
    /// Linked to function: variable: isResuming
    ///
    /// Parameters:
    /// none
    ///
    /// Emits when the individual site has been added, edited or deleted
    let dismissResuming = PassthroughSubject<Void, Never>()

    
    
    private init() {}
    
}


