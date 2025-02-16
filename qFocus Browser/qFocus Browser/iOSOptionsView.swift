//
//  iOSOptionsView.swift
//  qFocus Browser
//
//  Created by Sascha on 2024-12-08.
//
#if os(iOS)
import SwiftUI
import SwiftData
import UIKit







// MARK: iOS Options View
struct iOSOptionsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject var globals: GlobalVariables
    @EnvironmentObject var startViewModel: StartViewModel

    @Query(sort: \sitesStorage.siteOrder) var webSites: [sitesStorage]
    @Query() var settingsData: [settingsStorage]
    @Query(sort: \adBlockFilters.sortOrder) var adBlockLists: [adBlockFilters]

    @State private var sliderValue: Double = 3.0
    
    
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header ZStack for easy center of header
                ZStack {
                    HStack {
                        Button(action: {
                            do {
                                try modelContext.save()
                            } catch {
                                print("Error: Saving options failed.")
                            }
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Done")
                        }
                        Spacer()
                    }
                    .padding()

                    HStack {
                        Spacer()
                        Text("Options")
                            .font(.title)
                        Spacer()
                    }
                }

                // Combined List with multiple sections
                List {
                    // Websites Section
                    Section(header: Text("Websites")) {
                        ForEach(webSites.indices, id: \.self) { sitePointer in
                            NavigationLink(destination: iOSOptionsEditSite(editSite: webSites[sitePointer])) {
                                HStack {
                                    if let tempIcon = UIImage(data: webSites[sitePointer].siteFavIcon!) {
                                        Image(uiImage: tempIcon)
                                            .resizable()
                                            .frame(width: 25, height: 25)
                                            .clipShape(RoundedRectangle(cornerRadius: 18))
                                    } else {
                                        Image(uiImage: UIImage(systemName: "exclamationmark.circle")!)
                                            .resizable()
                                            .frame(width: 25, height: 25)
                                    }
                                    VStack {
                                        Text(webSites[sitePointer].siteName)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                        Text(webSites[sitePointer].siteURL)
                                            .font(.caption)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(.leading)
                                }
                            }
                        }
                    }

                    // Settings Section
                    Section {
                        @Bindable var settingsData = settingsData[0]

                        Toggle("Show Navigation Bar", isOn: $settingsData.showNavBar)

                        Toggle("Enable Face ID", isOn: $settingsData.faceIDEnabled)

                        NavigationLink(destination: AdBlockSettingsView(settingsData: settingsData)) {
                            HStack {
                                Text("Ad Blocking")
                                Image(systemName: "shield.fill")
                                    .foregroundColor(settingsData.enableAdBlock ? .green : .gray)
                                
                                Spacer()
                                
                                // Optional: Show count of enabled filters
                                if settingsData.enableAdBlock {
                                    Text("\(adBlockLists.filter { $0.enabled }.count) active")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                } else {
                                    Text("disabled")
                                        .font(.caption)
                                        .foregroundColor(.gray)

                                }
                            }
                        }

                        NavigationLink(destination: iOSAboutView()) {
                            Text("About")
                        }
                    } header: {
                        Text("Settings")
                    } footer: {
                        Text("Version \(globals.appVersion)")
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
    }

}






#endif
