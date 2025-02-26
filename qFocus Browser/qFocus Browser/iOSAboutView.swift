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
    @EnvironmentObject var collector: Collector


    
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
                        NavigationLink(
                            destination: ExternalWebView(url: URL(string: "https://qsascha.dev/qfocus-browser/")!)
                        ) {
                            HStack {
                                Text("about.header.appName")
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                
                                Image(systemName: "link.circle")
                                    .font(.title)
                                    .foregroundColor(.blue)
                            }
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
//                        .fixedSize(horizontal: false, vertical: true)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        NavigationLink(
                            destination: ExternalWebView(url: URL(string: "https://github.com/AdguardTeam/FiltersRegistry")!)
                        ) {
                            Text("about.link.adguardFilters")
                                .foregroundColor(.blue)
                        }

                        NavigationLink(
                            destination: ExternalWebView(url: URL(string: "https://github.com/AdguardTeam/SafariConverterLib")!)
                        ) {
                            Text("about.link.adguardConverter")
                                .foregroundColor(.blue)
                        }

                    }
                }
                
                // Copyright Notice
                HStack(spacing: 0) {
                    
                    Text("about.copyright")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 20)

                    NavigationLink(
                        destination: ExternalWebView(url: URL(string: "https://qSascha.dev")!)
                    ) {
                        Text(" qSascha")
                            .font(.footnote)
                            .foregroundColor(.blue)
                            .padding(.top, 20)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
            .onAppear() {
                collector.save(event: "Viewed", parameter: "About")
            }


        }
    }
    
}


#endif
