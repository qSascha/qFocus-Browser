//
//  iOSoptionsEditSite.swift
//  qFocus Browser
//
//  Created by Sascha on 2024-12-09.
//

import SwiftUI
import SwiftData
import UIKit



func fqdnOnly(from url: String) -> String {
    return url.replacingOccurrences(of: "https://", with: "")
              .replacingOccurrences(of: "http://", with: "")
}




struct iOSOptionsEditSite: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var collector: Collector

    var editSite: sitesStorage
    
    @State private var tempName: String
    @State private var tempURL: String
    @State private var faviconImage: UIImage?
    @FocusState private var isNameFieldFocused: Bool
    
    // Debouncing
    @State private var debounceTimer: Timer?
    
    init(editSite: sitesStorage) {
        self.editSite = editSite
        _tempName = State(initialValue: editSite.siteName)
        _tempURL = State(initialValue: editSite.siteURL)
    }
    


    func fetchFavicon(for url: String) {
        guard !url.isEmpty else { return }
        
        let fqdn = fqdnOnly(from: url)
        guard let iconURL = URL(string: "https://icons.duckduckgo.com/ip3/\(fqdn).ico") else { return }
        
        URLSession.shared.dataTask(with: iconURL) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                self.faviconImage = image
            }
        }.resume()
    }
    





    var body: some View {

            // Form Fields
            Form {
                Section {
                    // Name Field
                    HStack {
                        Text("optionsEdit.site.name")
                            .frame(width: 50, alignment: .leading)
                        TextField("", text: $tempName)
                            .focused($isNameFieldFocused)
                            .onChange(of: tempName) { _, newValue in
                                debounceTimer?.invalidate()
                                debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { _ in
                                    tempURL = "https://\(newValue.lowercased()).com"
                                    fetchFavicon(for: tempURL)
                                }
                            }

                        // Favicon Display
                        Spacer()
                        if let image = faviconImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        } else {
                            Image(systemName: "globe")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.gray)
                        }


                    }

                    // URL Field
                    HStack {
                        Text("optionsEdit.site.Link")
                            .frame(width: 50, alignment: .leading)
                        TextField("", text: $tempURL)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .onChange(of: tempURL) { _, newValue in
                                debounceTimer?.invalidate()
                                debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { _ in
                                    fetchFavicon(for: newValue)
                                }
                            }
                    }

                }
                header: {
                    Text("optionsEdit.site.header")
                }
                footer: {
                    Text("optionsEdit.site.footer")
                }
                .onAppear {
                    if tempName.isEmpty {
                        isNameFieldFocused = true
                    } else {
                        isNameFieldFocused = false
                    }
                    if !tempURL.isEmpty {
                        fetchFavicon(for: tempURL)
                    }
                }

                Section {
                    // Advanced Settings
                    NavigationLink(destination: iOSOptionsEditAdvanced(editSite: editSite)) {
                        Text("optionsEdit.navigation.advanced")
                    }
                }

            }
        .navigationTitle(tempName)
        .onDisappear{
            saveData()
        }
    }
    


    
    //MARK: Save and Dismiss
    private func saveData() {


        // If the URL changes then post a notification
        if  editSite.siteURL != tempURL {
            NotificationCenter.default.post(name: NSNotification.Name("UpdateViews"), object: nil)
        }
        
        // Update the site data
        editSite.siteName = tempName
        editSite.siteURL = tempURL
        
        // Save the favicon if available
        if let image = faviconImage {
            editSite.siteFavIcon = image.pngData()
        } else {
            editSite.siteFavIcon = UIImage(systemName: "globe")?.pngData()
        }
        
        // Handle empty name case
        if tempName.isEmpty {
            editSite.siteURL = ""
            editSite.siteFavIcon = UIImage(systemName: "globe")?
                .withTintColor(.gray, renderingMode: .alwaysTemplate)
                .pngData()
        }
        
        collector.save(event: "Site Added", parameter: tempURL)

        // Save changes
        do {
            try modelContext.save()

        } catch {
            print("Error saving site: \(error)")
        }
        
    }
}


