//
//  iOSoptionsEditSite.swift
//  qFocus Browser
//
//  Created by Sascha on 2024-12-09.
//
#if os(iOS)

import SwiftUI
import SwiftData
import UIKit



func fqdnOnly(from url: String) -> String {
    return url.replacingOccurrences(of: "https://", with: "")
              .replacingOccurrences(of: "http://", with: "")
}







// MARK: iOS Options - Edit Site
struct iOSOptionsEditSite: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject var globals: GlobalVariables

    @FocusState var focused: Bool?

    @Query(sort: \sitesStorage.siteOrder) var webSites: [sitesStorage]

    var editSite: sitesStorage

    @State private var tempName: String
    @State private var tempURL: String
    @State private var tempFavIcon: Data?
    @State private var allEmpty: Bool = true
    @State private var typingTimer: Timer?

    
    init(editSite: sitesStorage) {

        self.editSite = editSite
        _tempURL = State(initialValue: editSite.siteURL)
        _tempName = State(initialValue: editSite.siteName)
        _tempFavIcon = State(initialValue: editSite.siteFavIcon)

    }
    
    var body: some View {

        VStack (alignment: .leading, spacing: 0) {
            
            
            // ***** Header *****
            ZStack {
                HStack {
                    Button{
                        
                        globals.currentTab = 0
                        globals.previousTab = 0
                        globals.nextTab = 0

                        editSite.siteName = tempName
                        editSite.siteURL = tempURL
                        editSite.siteFavIcon = tempFavIcon

                        if tempName == "" {
                            editSite.siteURL = ""
                            editSite.siteFavIcon = UIImage(systemName: "exclamationmark.circle")?.pngData()
                        }
                        
                        do {
                            try modelContext.save()
                           
                            allEmpty = true

                            for webSite in webSites {
                                if webSite.siteName != "" {
                                    allEmpty = false
                                    break
                                }
                            }
                    
                            if allEmpty {
                                UserDefaults.standard.set(false, forKey: "onboardingComplete")
                            }

                        } catch {
                            print("Error: Saving edited Site failed.")
                        }

                        presentationMode.wrappedValue.dismiss()
                        
                    } label: {
                        Image(systemName: "chevron.backward")
                        Text("Save")
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
            
            


            // ***** Form: Fields and Icon *****
            Form {
                List {
                    Section(header: Text("Site Information")
                        .padding(.top)
                    ) {
                        HStack {
                            Text("Name")
                                .frame(width: 50, alignment: .leading)
                            TextField("", text: $tempName, onEditingChanged: { _ in
                                // Cancel previous timer when editing changes
                                self.typingTimer?.invalidate()
                            })
                                .padding(.leading)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disableAutocorrection(true)
                                .focused($focused, equals: true)
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        self.focused = true
                                    }
                                }
                        }
                        .listRowSeparator(.hidden)
                        .padding(.top, 5)

                        HStack {
                            Text("Link")
                                .frame(width: 50, alignment: .leading)
                            TextField("https://\(tempName.lowercased()).com", text: $tempURL, onEditingChanged: { _ in
                                // Cancel previous timer when editing changes
                                self.typingTimer?.invalidate()
                            })
                                .padding(.leading)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .textInputAutocapitalization(.never)
                                .disableAutocorrection(true)
                                .onChange(of: tempName) {
                                    tempURL = "https://\(tempName.lowercased()).com"
                                }
                        }
                        .listRowSeparator(.hidden)

                        VStack {
                            Spacer(minLength: 10)
                            
                            HStack {

                                Spacer()

                                let fqdnOnly = fqdnOnly(from: tempURL)
                                // Link: https://dev.to/derlin/get-favicons-from-any-website-using-a-hidden-google-api-3p1e
                                AsyncImage(url: URL(string: "https://icons.duckduckgo.com/ip3/\(fqdnOnly).ico")!) { image in
                                    if let image = image.image {
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 50, height: 32, alignment: .leading)
                                            .clipShape(RoundedRectangle(cornerRadius: 18))
                                            .onChange(of: image) {
                                                self.typingTimer?.invalidate()
                                                
                                                self.typingTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { _ in
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
                                                        let renderer = ImageRenderer(content: image)
                                                        tempFavIcon = renderer.uiImage?.pngData()
                                                    }
                                                }
                                            }

                                    } else if image.error != nil {
                                        Image(systemName: "exclamationmark.circle")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 32, height: 32)
                                            .foregroundColor(.red)
                                    }
                                }

                                Spacer()

                            }
                            
                            Spacer(minLength: 10)
                        }
                        .listRowSeparator(.hidden)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .navigationBarBackButtonHidden(true)

    }
}



#endif
