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
    @EnvironmentObject var collector: Collector

    @Query(sort: \sitesStorage.siteOrder) var webSites: [sitesStorage]
    @Query() var settingsData: [settingsStorage]
    @Query() var filterSettings: [adBlockFilterSetting]
    
    let iconSize : CGFloat = 30

//    @State private var sliderValue: Double = 3.0
    

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
                            Text("general.done")
                        }
                        Spacer()
                    }
                    .padding()

                    HStack {
                        Spacer()
                        Text("options.header.text")
                            .font(.title)
                        Spacer()
                    }
                }


                // Combined List with multiple sections
                List {

                    Section {
                        NavigationLink(destination: iOSPromotion()) {
                            HStack {
                                Image(uiImage: UIImage(named: "Promotion-BMC-logo")!)
                                    .resizable()
                                    .frame(width: iconSize * 1.3, height: iconSize*1.3)
                                    .cornerRadius(iconSize*1.3/2)
                                    .padding(.vertical, 2)

                                Text("options.settings.navigationPromotion")
                                    .padding(.leading)
                            }
                        }
                    }


                    // Websites Section
                    Section(header: Text("options.websites.header")) {
                        ForEach(webSites.indices, id: \.self) { sitePointer in
                            NavigationLink(destination: iOSOptionsEditSite(editSite: webSites[sitePointer])) {
                                HStack {


                                    if let tempIcon = UIImage(data: webSites[sitePointer].siteFavIcon!) {
                                        Image(uiImage: tempIcon)
                                            .resizable()
                                            .frame(width: iconSize, height: iconSize)
                                            .clipShape(RoundedRectangle(cornerRadius: iconSize/2))
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
                    iOSOptionsViewSettings()

                }
                .listStyle(InsetGroupedListStyle())
            }
            .onAppear() {
                collector.save(event: "Viewed", parameter: "Options")
            }
        }
    }
}





//MARK: Section: Settings
struct iOSOptionsViewSettings: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext
    
    @EnvironmentObject var globals: GlobalVariables
    @EnvironmentObject var startViewModel: StartViewModel
    @EnvironmentObject var collector: Collector
    
    @Query(sort: \sitesStorage.siteOrder) var webSites: [sitesStorage]
    @Query() var settingsData: [settingsStorage]
    @Query() var filterSettings: [adBlockFilterSetting]
    
    let iconSize : CGFloat = 30
    
    
    
    var body: some View {
        
        Section {
            @Bindable var settingsData = settingsData[0]

            Toggle("options.settings.toggleNavbar", isOn: $settingsData.showNavBar)

            Toggle("options.settings.toggleEnableFaceID", isOn: $settingsData.faceIDEnabled)

            NavigationLink(destination: AdBlockSettingsView(settingsData: settingsData)) {
                HStack {
                    Text("options.settings.NavigationAdBlocking")
                    Image(systemName: "shield.fill")
                        .foregroundColor(settingsData.enableAdBlock ? .green : .gray)
                    
                    Spacer()
                    
                    // Updated: Show count of enabled filters using the new model
                    if settingsData.enableAdBlock {
                        Text("\(filterSettings.filter { $0.enabled }.count) adblock.activeCounts")
                            .font(.caption)
                            .foregroundColor(.gray)
                    } else {
                        Text("options.settings.adblockLabelDisabled")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }

            NavigationLink(destination: iOSAboutView()) {
                Text("options.settings.navigationAbout")
            }
        } header: {
            Text("options.settings.header")
        } footer: {
            Text("general.version \(globals.appVersion)")
        }

        
    }
    
}




#endif


