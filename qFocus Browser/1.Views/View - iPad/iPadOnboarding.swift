//
//  iPadOnboarding.swift
//  qFocus Browser
//
//
import SwiftUI
import FactoryKit



struct iPadOnboarding: View {
    @InjectedObject(\.onboardingVM) var viewModel: OnboardingVM
    @Environment(\.dismiss) private var dismiss
    
    
    
    var body: some View {
        ZStack(alignment: .bottom) {
            
            contentForStep
            .padding(.horizontal, 100)
            .ignoresSafeArea(edges: .bottom)
            
            if #available(iOS 26.0, *) {
                navigationButtons
                
            } else if #available(iOS 18.5, *) {
                //Legacy Versions
                navigationButtons18
            }
            
        }
        
    }
    
    
    @ViewBuilder
    private var contentForStep: some View {
        switch viewModel.currentStep {
        case 1: iPadWelcome()
        case 2: iPadPrivacy()
        case 3: iPadAuthentication()
//        case 4: iPadPhotos()
        case 4: iPadFirstSite()
        case 5: iPadAdBlockSelect()
        case 6: iPadDone()
        default: EmptyView()
        }
    }
    
    
    
    // MARK: - Navigation 26
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
        .padding(.horizontal, 30)
        .padding(.bottom, 20)
        .onAppear {
#if DEBUG
            print("⚠️ iOSOnboarding")
#endif
        }
        
        
    }
    

    
    
    // MARK: - Navigation 18
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
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.gray.gradient.opacity(0.94))
                .cornerRadius(20)
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
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.gray.gradient.opacity(0.94))
                .cornerRadius(20)
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
                .padding(.horizontal, 10)
                .padding(.vertical, 3)
                .background(Color.gray.gradient.opacity(0.94))
                .cornerRadius(20)
            }
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 20)
        
    }
    

    
    
    
}



#Preview {
    iPadOnboarding()
}
