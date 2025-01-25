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
    
    @ObservedObject var viewModel: ContentViewModel
    
    @Query(sort: \sitesStorage.siteOrder) var webSites: [sitesStorage]
    @Query() var settingsData: [settingsStorage]

    @State private var sliderValue: Double = 3.0  // Default to 3 (0.8 opacity)

    
    var body: some View {

        /**     Header Section with "Done" button to close view     **/
        NavigationView {

            VStack(spacing: 0) {

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

                /**     Generate List of all Websites      **/

                List(webSites.indices, id: \.self) { sitePointer in
                    NavigationLink(destination: iOSOptionsEditSite(editSite: webSites[sitePointer])) {
                        HStack {
                            if let tempIcon = UIImage(data: webSites[sitePointer].siteFavIcon!) {
                                // siteFavIcon not nil, no problem
                                Image(uiImage: tempIcon)
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .clipShape(
                                        RoundedRectangle(
                                            cornerRadius: 18
                                        )
                                    )
                            } else {
                                // Image is empty or invalid -> Set default icon
                                let tempIcon = UIImage(systemName: "exclamationmark.circle")
                                // Use tempIcon
                                Image(uiImage: tempIcon!)
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
                

                List {
                    Section {
                        // ***** Various settings *****
                        @Bindable var settingsData = settingsData[0]
                        Toggle("Navigation bar on top", isOn: $settingsData.navOnTop)
                        Toggle("Hide main icons", isOn: $settingsData.hideMainIcons)
                        Toggle("Hide side icons", isOn: $settingsData.hideSideIcons)
                        Toggle("Big icons", isOn: $settingsData.bigIcons)
                        Toggle("Enable adblocker", isOn: $settingsData.enableAdBlock)
                            .onChange(of: settingsData.enableAdBlock) { oldValue, newValue in
                                Task {
                                    await viewModel.toggleBlocking(isEnabled: newValue)
                                }
                            }

                        HStack {
                            Text("Bar opacity")
                                .padding(.trailing, 30)
                            Slider(value: $settingsData.opacity, in: 0.7...1.0, step: 0.1)

                        }
                        // *****     About Section with version number *****
                        NavigationLink(destination: iOSAboutView()) {
                            Text("About")
                        }
                    } footer: {
                        Text("Version 25.01")
                    }
                }
                .contentMargins(.top, 0)
                
                Spacer()

            }
        }
    }


}






#endif
