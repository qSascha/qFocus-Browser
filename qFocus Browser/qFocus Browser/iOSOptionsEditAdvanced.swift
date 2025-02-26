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
    @EnvironmentObject var collector: Collector

    @Bindable var editSite: sitesStorage


    init(editSite: sitesStorage) {
        self.editSite = editSite
    }

    
    
    var body: some View {

        List {

            // Header with Save Button
/*
            ZStack {
                HStack {
                    Button(action: saveAndDismiss) {
                        HStack {
                            Image(systemName: "chevron.backward")
                            Text("general.save")
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
*/
            
            Section {
                Toggle("optionsAdvanced.enableBlocker.toggle", isOn: $editSite.enableJSBlocker)
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
            }
            header: {
                Text("optionsAdvanced.enableBlocker.header")
            } footer: {
                Text("optionsAdvanced.enableBlocker.footer")
            }
            
            // Desktop Site
            Section {
                Toggle("optionsAdvanced.desktopSite.toggle", isOn: Binding(
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

            }
            header: {
                Text("optionsAdvanced.desktopSite.header")
            } footer: {
                Text("optionsAdvanced.desktopSite.footer")
            }

        }
        .navigationTitle(editSite.siteName)
        .onAppear() {
            collector.save(event: "Viewed", parameter: "Advanced Options")
        }
        .onDisappear{
            saveData()
        }

    }
    


    
    //MARK: Save Data on Exit
    private func saveData() {

 
        // Save changes
        do {
            try modelContext.save()
        } catch {
            print("Error saving site: \(error)")
        }
        
    }
}


