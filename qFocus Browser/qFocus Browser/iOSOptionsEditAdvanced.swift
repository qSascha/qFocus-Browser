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
    @EnvironmentObject var startViewModel: StartViewModel

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
                            Text("save_button".localized)
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
                    Toggle("toggle_enable_javascript".localized, isOn: $editSite.enableJSBlocker)
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
                    Text("header_javascript".localized)
                } footer: {
                    Text("greasyfork_text".localized)
                }
                
                // Desktop Site
                Section {
                    Toggle("toggle_request_desktop".localized, isOn: Binding(
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
                            startViewModel.updateDesktopMode(for: editSite.siteOrder - 1, requestDesktop: newValue)
                        }
                    ))

                } header: {
                    Text("header_desktop".localized)
                } footer: {
                    Text("desktop_text".localized)
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


