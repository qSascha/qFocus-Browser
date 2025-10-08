//
//  iPadFirstSite.swift
//  qFocus Browser
//
//
import SwiftUI 
import FactoryKit



struct iPadFirstSite: View {
    @InjectedObject(\.firstSiteVM) var viewModel: FirstSiteVM
    @InjectedObject(\.onboardingVM) var onboardingModel: OnboardingVM
    @FocusState private var isNameFieldFocused: Bool
    
    
    var body: some View {

        VStack(spacing: 60) {
            // Header
            Text("onboarding.050firstsite.header")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding(.top, 80)
            
            Text(String(localized: "onboarding.050firstsite.text"))
                .multilineTextAlignment(.center)
                .lineSpacing(8)
            
            VStack(spacing: 30) {
                
                // Name Field
                HStack {
                    Text("onboarding.050firstsite.formName")
                        .frame(width: 50, alignment: .leading)
                    TextField("", text: $viewModel.siteName)
                        .autocorrectionDisabled(true)
                        .focused($isNameFieldFocused)
                        .onAppear() {
                            if viewModel.siteName.isEmpty {
                                onboardingModel.canProceed = false
                            }
                        }
                        .onChange(of: viewModel.siteName) {
                            onboardingModel.canProceed = false
                            viewModel.statusText = String(localized: "onboarding.050firstsite.statusChecking")
                            viewModel.onNameChange(viewModel.siteName)
                        }
                }
                
                // URL Field
                HStack {
                    Text("onboarding.050firstsite.formLink")
                        .frame(width: 50, alignment: .leading)
                    TextField("", text: $viewModel.siteURL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .onChange(of: viewModel.siteURL) {
                            onboardingModel.canProceed = false
                            viewModel.statusText = String(localized: "onboarding.050firstsite.statusChecking")
                            let noSpaces = viewModel.siteURL.replacingOccurrences(of: " ", with: "")
                            if noSpaces != viewModel.siteURL {
                                viewModel.siteURL = noSpaces
                            }
                            viewModel.onURLChange(noSpaces)
                            
                            Task { @MainActor in
                                viewModel.checkReachabilityAndUpdate(viewModel.siteURL) { reachable in
                                    if viewModel.siteName.isEmpty{
                                        onboardingModel.canProceed = false
                                    } else {
                                        if reachable == false {
                                            viewModel.statusText = String(localized: "onboarding.050firstsite.statusCantBeReached")
                                            onboardingModel.canProceed = false
                                        } else {
                                            viewModel.statusText = String(localized: "onboarding.050firstsite.statusGood")
                                            onboardingModel.canProceed = true
                                        }
                                    }
                                }
                            }

                        }

                }
                
                // Status Field
                HStack {
                    Text("onboarding.050firstsite.formStatus")
                        .font(.system(size: 12))
                        .frame(width: 50, alignment: .leading)
                        .foregroundColor(.blue)
                    
                    TextField("", text: $viewModel.statusText)
                        .font(.system(size: 12))
                        .foregroundColor(.blue)
                        .allowsHitTesting(false)

                }

                
                // Favicon
                if let image = viewModel.faviconImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 32))
                }
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(16)
            .onAppear {
                viewModel.loadFirstSiteIfAvailable()
                isNameFieldFocused = true
            }
            .onDisappear {
                viewModel.saveSite()
            }
            
            Spacer()
        }

    }
    
}
