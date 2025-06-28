//
//  FirstSite.swift
//  qFocus Browser
//
//
import SwiftUI
import FactoryKit



struct FirstSite: View {
    @InjectedObject(\.firstSiteVM) var viewModel: FirstSiteVM
    @FocusState private var isNameFieldFocused: Bool

    
    var body: some View {
        VStack(spacing: 20) {
            // Name Field
            HStack {
                Text("onboarding.050firstsite.formName")
                    .frame(width: 50, alignment: .leading)
                TextField("", text: $viewModel.siteName)
                    .autocorrectionDisabled(true)
                    .focused($isNameFieldFocused)
                    .onChange(of: viewModel.siteName) {
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
                        viewModel.onURLChange(viewModel.siteURL)
                    }            }

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
