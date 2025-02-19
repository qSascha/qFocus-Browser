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
                            Text("about.header.appName")
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

                        Text("general.version \(globals.appVersion)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)

                // Description Section
                Group {
                    Text("about.thanks.header")
                        .font(.headline)
                    
                    Text("about.thanks.text1")
                        .fixedSize(horizontal: false, vertical: true)
                    Text("about.thanks.text2")
                        .fixedSize(horizontal: false, vertical: true)
                }
                

                // Credits Section
                Group {
                    Text("about.credits.header")
                        .font(.headline)
                    
                    Text("about.credits.text")
                        .fixedSize(horizontal: false, vertical: true)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Link("about.link.adguardFilters", destination: URL(string: "https://github.com/AdguardTeam/FiltersRegistry")!)
                            .foregroundColor(.blue)
                        Link("about.link.adguardConverter", destination: URL(string: "https://github.com/AdguardTeam/SafariConverterLib")!)
                            .foregroundColor(.blue)

                    }
                }
                
                // Copyright Notice
                HStack(spacing: 0) {
                    
//                    Text("© 2025")
                    Text("about.copyright")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 20)
                    Link(" qSascha", destination: URL(string: "https://qSascha.dev")!)
                        .font(.footnote)
                        .foregroundColor(.blue)
                        .padding(.top, 20)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
        }
    }
    
}


#endif
