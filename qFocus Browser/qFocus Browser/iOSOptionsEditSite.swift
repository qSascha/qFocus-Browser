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
    
    // Site being edited
    var editSite: sitesStorage
    
    // UI State
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
                    Text(tempName)
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                }
            }
            
            // Form Fields
            Form {
                Section(header: Text("Site Information").padding(.top)) {
                    // Name Field
                    HStack {
                        Text("Name")
                            .frame(width: 50, alignment: .leading)
                        TextField("", text: $tempName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .focused($isNameFieldFocused)
                            .onChange(of: tempName) { _, newValue in
                                debounceTimer?.invalidate()
                                debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { _ in
                                    tempURL = "https://\(newValue.lowercased()).com"
                                    fetchFavicon(for: tempURL)
                                }
                            }
                    }
                    .padding(.top, 5)
                    
                    // URL Field
                    HStack {
                        Text("Link")
                            .frame(width: 50, alignment: .leading)
                        TextField("", text: $tempURL)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .onChange(of: tempURL) { _, newValue in
                                debounceTimer?.invalidate()
                                debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { _ in
                                    fetchFavicon(for: newValue)
                                }
                            }
                    }
                    
                    // Favicon Display
                    HStack {
                        Spacer()
                        if let image = faviconImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 32)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            Image(systemName: "globe")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    .padding(.vertical, 10)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            isNameFieldFocused = true
            if !tempURL.isEmpty {
                fetchFavicon(for: tempURL)
            }
        }
    }
    


    
    //MARK: Save and Dismiss
    private func saveAndDismiss() {

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
            editSite.siteFavIcon = UIImage(systemName: "exclamationmark.circle")?.pngData()
        }
        
        // Save changes
        do {
            try modelContext.save()

            NotificationCenter.default.post(name: NSNotification.Name("URLUpdated"), object: nil)

        } catch {
            print("Error saving site: \(error)")
        }
        
        // Dismiss the view
        presentationMode.wrappedValue.dismiss()
    }
}


