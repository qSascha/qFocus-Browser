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
                    if let iconImage = UIImage(named: "AppIcon") {
                        Image(uiImage: iconImage)
                            .resizable()
                            .frame(width: 100, height: 100)
                    }

                    
                    // App Title and Version
                    VStack(spacing: 10) {

                        Text("about.header.appName")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .onTapGesture {
                                Collector.shared.save(event: "Viewed", parameter: "qSascha.dev/qFocus")
                                optionsVM.externalURL = IdentifiableURL(url: URL(string: "https://qsascha.dev/qfocus-browser/")!)
                            }

                        //TODO: Show correct version, from project settings
                        Text("general.version \(appVersion)")
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
                    
                    VStack(alignment: .leading, spacing: 8) {

                        Text("about.link.adguardFilters")
                            .foregroundColor(.blue)
                            .onTapGesture {
                                Collector.shared.save(event: "Viewed", parameter: "AdGuard-FiltersRegistry")
                                optionsVM.externalURL = IdentifiableURL(url: URL(string: "https://github.com/AdguardTeam/FiltersRegistry")!)
                            }

                        Text("about.link.adguardConverter")
                            .foregroundColor(.blue)
                            .onTapGesture {
                                Collector.shared.save(event: "Viewed", parameter: "AdGuard-SafariConverterLib")
                                optionsVM.externalURL = IdentifiableURL(url: URL(string: "https://github.com/AdguardTeam/SafariConverterLib")!)
                            }

                    }
                }
                
                
                // Terms Section
                Group {
                    Text("about.eula.header")
                        .font(.headline)
                        .padding(.top, 30)

                    Text("about.eula.text")
                    
                    VStack(alignment: .leading, spacing: 8) {

                        Text("about.eula.link")
                            .foregroundColor(.blue)
                            .onTapGesture {
                                Collector.shared.save(event: "Viewed", parameter: "EULA")
                                optionsVM.externalURL = IdentifiableURL(url: URL(string: "https://qsascha.dev/licensed-application-end-user-license-agreement/")!)
                            }

                    }
                }
                
                
                // Copyright Notice
                HStack(spacing: 0) {
                    
                    Text("© \(copyRightYear) ")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 20)

                    Text("qSascha")
                        .font(.footnote)
                        .foregroundColor(.blue)
                        .padding(.top, 20)
                        .onTapGesture {
                            Collector.shared.save(event: "Viewed", parameter: "qSascha.dev")
                            optionsVM.externalURL = IdentifiableURL(url: URL(string: "https://qSascha.dev")!)
                        }

                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
            .onAppear() {
                Collector.shared.save(event: "Viewed", parameter: "Options-About")
            }


        }
    }
    
}


