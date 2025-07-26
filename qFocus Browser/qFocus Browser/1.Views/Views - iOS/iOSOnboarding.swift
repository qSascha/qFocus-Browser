//
//  iOSOnboarding.swift
//  qFocus Browser
//
//

import SwiftUI
import FactoryKit



struct iOSOnboarding: View {
    @InjectedObject(\.onboardingVM) var viewModel: OnboardingVM
    @Environment(\.dismiss) private var dismiss
    
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            VStack(spacing: 0) {
                
                VStack(spacing: 10) {
                    // Header
                    Text(headerForStep)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.top, 40)
                    
                    Spacer()
                    
                    // Main Content
                    contentForStep
                        .padding(.horizontal, 20)
                }
            }
            .ignoresSafeArea(edges: .bottom)
            
            if #available(iOS 26.0, *) {
                navigationButtons
                
            } else if #available(iOS 18.5, *) {
                //Legacy Versions
                navigationButtons18
            }
            
        }
        
    }
    
    
    private var headerForStep: String {
        switch viewModel.currentStep {
        case 1: return String(localized: "onboarding.010welcome.header")
        case 2: return String(localized: "onboarding.020privacy.header")
        case 3: return String(localized: "onboarding.030faceID.header")
        case 4: return String(localized: "onboarding.040photos.header")
        case 5: return String(localized: "onboarding.050firstsite.header")
        case 6: return String(localized: "onboarding.060adblock.header")
        case 7: return String(localized: "onboarding.070done.header")
        default: return ""
        }
    }
    
    
    
    @ViewBuilder
    private var contentForStep: some View {
        switch viewModel.currentStep {
        case 1: Welcome()
        case 2: Privacy()
        case 3: FaceID()
        case 4: Photos()
        case 5: FirstSite()
        case 6: AdBlockSelect()
        case 7: Done()
        default: EmptyView()
        }
    }
    
    
    
    // MARK: - Navigation
    @available(iOS 26.0, *)
    private var navigationButtons: some View {
        
        HStack {
            if viewModel.currentStep > 1 {
                
                Button(action: { viewModel.previousStep() }) {
                    Image(systemName: "arrow.left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                        .padding(10)
                }
            }
            
            Spacer()
            
            if viewModel.currentStep < viewModel.totalSteps {
                
                Button(action: viewModel.nextStep) {
                    Image(systemName: "arrow.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                        .padding(10)
                }
                .disabled(!viewModel.canProceed)
            } else {
                
                Button(action: {
                    viewModel.completeOnboarding()
                    dismiss()
                }) {
                    Image(systemName: "checkmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                        .padding(10)
                }
            }
        }
        .buttonStyle(.glass)
        .padding(.horizontal, 20)
        .onAppear {
#if DEBUG
            print("⚠️ iOSOnboarding")
#endif
        }
        
        
    }
    

    
    
    // MARK: - Navigation
    @available(iOS 18.5, *)
    private var navigationButtons18: some View {
        
        HStack {
            if viewModel.currentStep > 1 {
                
                Button(action: { viewModel.previousStep() }) {
                    Image(systemName: "arrow.left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                        .padding(10)
                }
            }
            
            Spacer()
            
            if viewModel.currentStep < viewModel.totalSteps {
                
                Button(action: viewModel.nextStep) {
                    Image(systemName: "arrow.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                        .padding(10)
                }
                .disabled(!viewModel.canProceed)
            } else {
                
                Button(action: {
                    viewModel.completeOnboarding()
                    dismiss()
                }) {
                    Image(systemName: "checkmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                        .padding(10)
                }
            }
        }
        .background(Color.gray.opacity(0.5))
        .cornerRadius(20)
        .padding(.horizontal, 20)
        .onAppear {
#if DEBUG
            print("⚠️ iOSOnboarding")
#endif
        }
        
        
    }
    

    
    
    
}



#Preview {
    iOSOnboarding()
}
