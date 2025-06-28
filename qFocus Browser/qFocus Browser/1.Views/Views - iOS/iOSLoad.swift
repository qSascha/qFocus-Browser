//
//  iOSLoad.swift
//  qFocus Browser
//
//
import SwiftUI
import FactoryKit



struct iOSLoad: View {
    @InjectedObject(\.loadingVM) var viewModel: LoadingVM


    var body: some View {
        
        VStack(spacing: 100) {

            Spacer()

            Text("qFocus Browser")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.white)
            
            Image("OnboardingWelcome")
                .resizable()
                .frame(width: 150, height: 150)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)

            VStack(spacing: 0) {
                Text("brought to you")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.bottom, 8)
                
                Text("by")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.bottom, 20)
                
                Text("qSascha")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            Spacer()

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.blue)
        .ignoresSafeArea()
        .onAppear {
            viewModel.start(platform: DeviceInfo.shared.platform)
#if DEBUG
            print("⚠️ iOSLoad")
#endif
        }
        .sheet(isPresented: $viewModel.showAuthenticationSheet) {
            iOSAuth { success in
                if success {
                    viewModel.authenticationSucceeded()
                } else {
                    viewModel.authenticationFailed()
                }
            }
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $viewModel.showAuthenticationFailedSheet) {
            iOSAuthFail(retryAction: {
                viewModel.retryAuthentication()
            })
            .presentationDetents([.medium])
        }

    }
}
