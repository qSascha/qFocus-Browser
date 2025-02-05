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

    @ObservedObject var viewModel: ContentViewModel
    
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
                        Picker("Navigation", selection: $settingsData.navOption) {
                            ForEach(navBarMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue)
                                    .tag(mode)
                            }
                        }
                        .onChange(of: settingsData.navOption) { oldValue, newValue in
                            if newValue == .top {
                                settingsData.showTopBar = true
                            }
                        }
                        
                        Toggle("Show Top Bar", isOn: $settingsData.showTopBar)
                            .disabled(settingsData.navOption == .top)

                        Toggle("Show Bottom Bar", isOn: $settingsData.showBottomBar)
                        HStack {
                            Text("Bar opacity")
                                .padding(.trailing, 30)
                            Slider(value: $settingsData.opacity, in: 0.7...1.0, step: 0.1)
                        }
                        
                        NavigationLink(destination: AdBlockSettingsView(settingsData: settingsData, viewModel: viewModel)) {
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
/*
                        Toggle("Enable adblocker", isOn: $settingsData.enableAdBlock)
                            .onChange(of: settingsData.enableAdBlock) { oldValue, newValue in
                                Task {
                                    await viewModel.toggleBlocking(isEnabled: newValue)
                                }
                            }
*/
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
