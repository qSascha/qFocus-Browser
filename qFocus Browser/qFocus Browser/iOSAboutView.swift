//
//  iOSAboutView.swift
//  qFocus Browser
//
//  Created by Sascha on 2024-12-21.
//
#if os(iOS)
import SwiftUI
import UIKit




struct iOSAboutView: View {
    @EnvironmentObject var globals: GlobalVariables
    @State private var showWebView = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // App Icon and Title
                VStack(alignment: .center, spacing: 15) {
                    // App Icon
                    if let iconImage = UIImage(named: "OnboardingWelcome") {
                        Image(uiImage: iconImage)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    
                    // App Title and Version
                    VStack(spacing: 10) {
                        HStack {
                            Text("header_qFocus".localized)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)

                            Image(systemName: "link.circle")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                        .onTapGesture {
                            showWebView = true
                        }
                        .fullScreenCover(isPresented: $showWebView) {
                            ExternalWebViewWrapper(url: URL(string: "https://qsascha.dev")!)
                        }

                        Text("version".localized(with: globals.appVersion))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)

                // Description Section
                Group {
                    Text("header_thank_you".localized)
                        .font(.headline)
                    
                    Text("thankyou_text1".localized)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("thankyou_text2".localized)
                        .fixedSize(horizontal: false, vertical: true)
                }
                

                // Credits Section
                Group {
                    Text("header_credits".localized)
                        .font(.headline)
                    
                    Text("credits_text".localized)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Link("AdGuard Filters", destination: URL(string: "https://github.com/AdguardTeam/FiltersRegistry")!)
                            .foregroundColor(.blue)
                        Link("AdGuard Filter Converter", destination: URL(string: "https://github.com/AdguardTeam/SafariConverterLib")!)
                            .foregroundColor(.blue)

                    }
                }
                
                // Copyright Notice
                HStack(spacing: 0) {
                    
                    Text("© 2025 ")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 20)
                    Link("qSascha", destination: URL(string: "https://qSascha.dev")!)
                        .font(.footnote)
                        .foregroundColor(.blue)
                        .padding(.top, 20)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
        }
    }
    
    // Helper function to create bullet points
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
            Text(text)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// Preview provider
#Preview {
    iOSAboutView()
}

#endif
