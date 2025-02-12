//
//  iOSOptionsEditAdvanced.swift
//  qFocus Browser
//
//  Created by Sascha on 2025-02-11.
//
import SwiftUI
import SwiftData
import UIKit


struct iOSOptionsEditAdvanced: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var viewModel: ContentViewModel

    @Bindable var editSite: sitesStorage


    init(editSite: sitesStorage) {
        self.editSite = editSite
    }

    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with Save Button
            ZStack {
                HStack {
                    Button(action: saveAndDismiss) {
                        HStack {
                            Image(systemName: "chevron.backward")
                            Text("Save")
                        }
                    }
                    Spacer()
                }
                .padding()
                
                HStack {
                    Spacer()
                    Text(editSite.siteName)
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                }
                Spacer()
            }

            
            Form {
                
                //JavaScript
                Section {
                    Toggle("Enable JavaScript ad-blocker", isOn: $editSite.enableJSBlocker)
                        .onChange(of: editSite.enableJSBlocker) { _, newValue in
                            // Save changes
                            do {
                                try modelContext.save()
                            } catch {
                                print("Error saving site: \(error)")
                            }

                            // Post notification to update the web view
                            NotificationCenter.default.post( name: NSNotification.Name("UpdateViews"), object: nil )
                        }
                } header: {
                    Text("JavaScript")
                } footer: {
                    Text("qFocus Browser has several GreasyForks (https://greasyfork.org) scripts that can help block ads. These are implemented and enabled by default, but if you have any issues then you can disable them here.")
                }
                
                // Desktop Site
                Section {
//                    Toggle("Request Desktop Site", isOn: $editSite.requestDesktop)
                    Toggle("Request Desktop Site", isOn: Binding(
                        get: { editSite.requestDesktop },
                        set: { newValue in
                            // Save changes
                            editSite.requestDesktop = newValue
                            do {
                                try modelContext.save()
                            } catch {
                                print("Error saving site: \(error)")
                            }

                            // Update the web view configuration
                            viewModel.updateDesktopMode(for: editSite.siteOrder - 1, requestDesktop: newValue)
                        }
                    ))

                } header: {
                    Text("Desktop Site")
                } footer: {
                    Text("Some website, like Facebook Messenger (https://messenger.com), only work properly on a desktop browser. Here you can enable this setting to use the site even on your mobile phone.")
                }

            }
        }
        .navigationBarBackButtonHidden(true)

    }
    


    
    //MARK: Save and Dismiss
    private func saveAndDismiss() {

 
        // Save changes
        do {
            try modelContext.save()
        } catch {
            print("Error saving site: \(error)")
        }
        
        // Dismiss the view
        presentationMode.wrappedValue.dismiss()
    }
}


