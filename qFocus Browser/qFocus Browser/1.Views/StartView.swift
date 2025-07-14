//
//  StartView.swift
//  qFocus Browser
//
//

import SwiftUI
import FactoryKit



struct StartView: View {
    @InjectedObject(\.startVM) var viewModel: StartVM

    
    
    var body: some View {
        StartViewSecond()

    }
}



//MARK: Start View Second
struct StartViewSecond: View {
    @InjectedObject(\.startVM) var viewModel: StartVM
    @InjectedObject(\.onboardingVM) var onboardingVM: OnboardingVM
    @InjectedObject(\.loadingVM) var loadingVM: LoadingVM

    
    
    var body: some View {
        Group {
            switch viewModel.state {
            case .initial:
                EmptyView()
            case .loading:
                loadingView
            case .onboarding:
                onboardingView
            case .main:
                mainView
            }
        }
        .onChange(of: onboardingVM.isComplete) {
            // When onboarding is done we update the StartView.
            if onboardingVM.isComplete {
                viewModel.evaluateStartup()
            }
        }
        .onChange(of: loadingVM.isFinished) {
            // When authentication was successful we show the MainView.
            if loadingVM.isFinished {
                viewModel.moveToMain(platform: .iOS)
            }
        }
    }
    
    
    
    //MARK: Loading
    @ViewBuilder
    private var loadingView: some View {
        switch viewModel.state {
        case .loading(let platform):
            switch platform {
            case .iOS:
                iOSLoad()
//            case .iPadOS: iPadLoad()
//            case .macOS: macLoad()
//            case .visionOS: visionLoad()
            default: EmptyView()
            }
        default:
            EmptyView()
        }

    }
 
    
    
    //MARK: Onboarding
    @ViewBuilder
    private var onboardingView: some View {
        switch viewModel.state {
        case .onboarding(let platform):
            switch platform {
            case .iOS:
                iOSOnboarding()
//            case .iPadOS: iPadOnboarding()
//            case .macOS: macOnboarding()
//            case .visionOS: visionOnboarding()
            default: EmptyView()
            }
        default:
            EmptyView()
        }
    }

    
    //MARK: Main
    @ViewBuilder
    private var mainView: some View {
        switch viewModel.state {
        case .main(let platform):
            switch platform {
            case .iOS:
                iOSMain()
//            case .iPadOS: iPadMain()
//            case .macOS: macMain()
//            case .visionOS: visionMain()
            default: EmptyView()
            }
        default:
            EmptyView()
        }
    }

    
}
