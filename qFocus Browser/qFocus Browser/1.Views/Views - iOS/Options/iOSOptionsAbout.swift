//
//  iOSOptionsAbout.swift
//  qFocus Browser
//
//
import SwiftUI
import UIKit
import FactoryKit



struct iOSAbout: View {
    @InjectedObject(\.optionsVM) var optionsVM: OptionsVM

    
    
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

                        Text("about.header.appName")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .onTapGesture {
                                optionsVM.externalURL = IdentifiableURL(url: URL(string: "https://qsascha.dev/qfocus-browser/")!)
                            }

                        //TODO: Show correct version, from project settings
                        Text("general.version v25.05")
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
                        .padding(.top, 30)

                    Text("about.credits.text")
//                        .fixedSize(horizontal: false, vertical: true)
                    
                    VStack(alignment: .leading, spacing: 8) {

                        Text("about.link.adguardFilters")
                            .foregroundColor(.blue)
                            .onTapGesture {
                                optionsVM.externalURL = IdentifiableURL(url: URL(string: "https://github.com/AdguardTeam/FiltersRegistry")!)
                            }

                        Text("about.link.adguardConverter")
                            .foregroundColor(.blue)
                            .onTapGesture {
                                optionsVM.externalURL = IdentifiableURL(url: URL(string: "https://github.com/AdguardTeam/SafariConverterLib")!)
                            }

                    }
                }
                
                
                // Copyright Notice
                HStack(spacing: 0) {
                    
                    Text("about.copyright")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 20)

                    Text(" qSascha")
                        .font(.footnote)
                        .foregroundColor(.blue)
                        .padding(.top, 20)
                        .onTapGesture {
                            optionsVM.externalURL = IdentifiableURL(url: URL(string: "https://qSascha.dev")!)
                        }

                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
            .onAppear() {
                //TODO: Collector
//                collector.save(event: "Viewed", parameter: "About")
            }


        }
    }
    
}


