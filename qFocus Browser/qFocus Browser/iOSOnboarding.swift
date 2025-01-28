//
//  iOSOnboarding.swift
//  qFocus Browser
//
//  Created by Sascha on 2024-12-21.
//


import SwiftUI
import SwiftData
import Photos
import AVFoundation









//MARK: Re-Initialize Data
func reinitializeData(modelContext: ModelContext, firstSiteName: String, firstSiteURL: String, firstSiteFavIcon: Data) {
    // Delete existing records
    do {
        // Delete sites
        let fetchDescriptor = FetchDescriptor<sitesStorage>()
        let existingSites = try modelContext.fetch(fetchDescriptor)
        for site in existingSites {
            modelContext.delete(site)
        }
        
        // Delete settings
        let settingsDescriptor = FetchDescriptor<settingsStorage>()
        let existingSettings = try modelContext.fetch(settingsDescriptor)
        for setting in existingSettings {
            modelContext.delete(setting)
        }
        
        // Delete ad block filters
        let adBlockDescriptor = FetchDescriptor<adBlockFilters>()
        let existingAdBlock = try modelContext.fetch(adBlockDescriptor)
        for filter in existingAdBlock {
            modelContext.delete(filter)
        }
        
        try modelContext.save()
    } catch {
        // Handle error appropriately for your app
    }
    
    // Initialize with default values
    initializeFiltersStorage(context: modelContext)
    initializeWebSitesStorage(context: modelContext)
    initializeDefaultSettings(context: modelContext)
    
    // Add first site enter by user during onboarding
    let descriptor = FetchDescriptor<sitesStorage>(
        predicate: #Predicate<sitesStorage> { site in
            site.siteOrder == 1
        }
    )
    do {
        if let siteToUpdate = try modelContext.fetch(descriptor).first {
            siteToUpdate.siteName = firstSiteName
            siteToUpdate.siteURL = firstSiteURL
            siteToUpdate.siteFavIcon = firstSiteFavIcon
            
            try modelContext.save()
        } else {
            print("ERROR: No record found for updating.")
        }
    } catch {
        print("ERROR: Updating \"First Site\" failed: \(error.localizedDescription)")
    }
    
    
}




// MARK: Show Navigation
struct showNavigation: View {
    @EnvironmentObject var globals: GlobalVariables
    @Environment(\.modelContext) private var modelContext

    
    
    
    var body: some View {

        // ***** Steps
        // 1 - Welcome
        // 2 - Privacy
        // 3 - Photos
        // 4 - First Site
        // 5 - Done
        

        VStack {
            Spacer()

            HStack {
                if globals.onboardingStep > 1 {
                    Button(action: {
                        globals.onboardingStep -= 1
                    }, label: {
                        
                        Image(systemName: "arrow.left")
                            .resizable()
                            .foregroundColor(.blue)
                            .aspectRatio(contentMode: .fit)
                        
                    })
                    .frame(width: 40, height: 30, alignment: .center)
                    .padding(.leading, 20)
                    
                }

                Spacer()

                if (globals.onboardingStep < 4) || (globals.onboardingStep == 4 && globals.onboardingFirstSiteOK) {
                    Button(action: {
                        if globals.onboardingStep == 4 {
                            reinitializeData(modelContext: modelContext,firstSiteName: globals.tempSiteName, firstSiteURL: globals.tempSiteURL, firstSiteFavIcon: globals.tempSiteFavIcon!)
                            }
                        globals.onboardingStep += 1

                    }, label: {
                        
                        Image(systemName: "arrow.right")
                            .resizable()
                            .foregroundColor(.blue)
                            .aspectRatio(contentMode: .fit)
                    })
                    .frame(width: 40, height: 30, alignment: .center)
                    .padding(.trailing, 20)

                } else if globals.onboardingStep == 5 {
                    Button(action: {
                        globals.onboardingStep = 4
                        UserDefaults.standard.set(true, forKey: "onboardingComplete")
                        print("Onboarding Done")
                            
                    }, label: {
                        
                        Image(systemName: "checkmark")
                            .resizable()
                            .foregroundColor(.blue)
                            .aspectRatio(contentMode: .fit)
                    })
                    .frame(width: 50, height: 40, alignment: .center)
                    .padding(.trailing, 20)
                    
                }
            }
            .padding(.bottom, 30)
            .onAppear {
                print(FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!)

            }
        }
    }
}





// MARK: Show Content
struct showContent: View {

    var header: String
    var text: String
    var picture: String
    

    var body: some View {
            
        VStack {
            Text(header)
                .padding(.bottom, 30)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Text(text)
                .padding(.leading, 40)
                .padding(.trailing, 40)
                .lineSpacing(10)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(.top, 30)
        
        VStack{
                
            if picture != "" {
            // ***** Invisible box to push down the image *****
                Rectangle()
                .opacity(0)
                .frame(width: 300, height: 200, alignment: .center)
            
                Spacer()

                Image(picture)
                    .resizable()
                    .foregroundColor(.blue)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150, alignment: .center)
                
                Spacer()
            }
        }
    }
}





// MARK: First Site
struct FirstSite: View {
    @Environment(\.modelContext) private var modelContext

    @EnvironmentObject var globals: GlobalVariables

    @FocusState var focused: Bool?

    @Query(sort: \sitesStorage.siteOrder) var webSites: [sitesStorage]
    @Query() var settingsData: [settingsStorage]
    @State private var typingTimer: Timer?





    var body: some View {


        VStack {
            // ***** Invisible box to push down the form *****
                Rectangle()
                .opacity(0)
                .frame(width: 300, height: 150, alignment: .center)

            // ***** Form: Fields and Icon *****
            Form {
                HStack {
                    Text("Name")
                        .frame(width: 50, alignment: .leading)
                    Spacer()
                    TextField("", text: $globals.tempSiteName, prompt: Text("Required"))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading)
                        .disableAutocorrection(true)
                        .focused($focused, equals: true)
                        .onAppear {
                            if globals.tempSiteName.isEmpty {
                                globals.onboardingFirstSiteOK = false
                            } else {
                                globals.onboardingFirstSiteOK = true
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                self.focused = true
                            }
                        }
                        .onChange(of: globals.tempSiteName) {
                            self.typingTimer?.invalidate()
                            if globals.tempSiteName.isEmpty {
                                globals.onboardingFirstSiteOK = false
                            } else {
                                globals.onboardingFirstSiteOK = true
                            }
                        }
                }
                .padding(.top, 8)
                .listRowSeparator(.hidden)

                HStack {
                    Text("Link")
                        .frame(width: 50, alignment: .leading)
                    Spacer()
                    TextField("https://\(globals.tempSiteName.lowercased()).com", text: $globals.tempSiteURL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.leading)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                        .onChange(of: globals.tempSiteName) {
                            self.typingTimer?.invalidate()
                            globals.tempSiteURL = "https://\(globals.tempSiteName.lowercased()).com"
                        }
                }
                .listRowSeparator(.hidden)
                
                VStack {
                    Spacer(minLength: 10)

                    HStack {
                        
                        Spacer()
                        
                        let fqdnOnly = fqdnOnly(from: globals.tempSiteURL)
                        // Link: https://dev.to/derlin/get-favicons-from-any-website-using-a-hidden-google-api-3p1e

                        AsyncImage(url: URL(string: "https://icons.duckduckgo.com/ip3/\(fqdnOnly).ico")!) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 32, alignment: .leading)
                                    .onAppear {
                                        globals.tempSiteFavIcon = image.asPNGData()
                                    }
                                    .clipShape(RoundedRectangle(cornerRadius: 18))
                                    
                            case .failure(_):
                                Image(systemName: "exclamationmark.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.red)
                                    .onAppear {
                                        globals.tempSiteFavIcon = Image(systemName: "exclamationmark.circle").asPNGData()
                                    }

                            case .empty:
                                Image(systemName: "exclamationmark.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 32, height: 32)
                                    .foregroundColor(.red)
                                    .onAppear {
                                        globals.tempSiteFavIcon = Image(systemName: "exclamationmark.circle").asPNGData()
                                    }

                                
                            @unknown default:    // Add this case to handle future enum cases
                                ProgressView()
                            }
                        }
                        
                        Spacer()
                        
                    }

                    Spacer(minLength: 10)
                }
            }
            .scrollContentBackground(.hidden)
            
            Spacer()
        }
    }
}


   


// MARK: Request Photo Access
struct RequestPhotosAccess: View {
//    @Environment(\.presentationMode) var presentationMode

    
    var body: some View {
        
        
        HStack {
            Spacer()
            
            Button(action: {

                PHPhotoLibrary.requestAuthorization { status in
                    switch status {
                    case .authorized:
                        print("Access granted")
                        // Proceed with accessing the Photos library
                    case .denied, .restricted, .notDetermined:
                        print("Access denied or restricted")
                    case .limited:
                        fatalError("Unexpected status")
                    @unknown default:
                        fatalError("Unexpected status")
                    }
                }
            }, label: {
                
                Text("Grant Photos Access")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(Color.white)
                
            })
            .cornerRadius(8)
            .padding(.bottom, 50)

            Spacer()
        }

    }
}




// MARK: Onboarding
struct Onboarding: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext
    
    @Query(
        filter: #Predicate<sitesStorage> { $0.siteName != "" },
        sort: \sitesStorage.siteOrder
    ) var webSites: [sitesStorage]
    
    @Query() var settingsData: [settingsStorage]
    
    @EnvironmentObject var globals: GlobalVariables
    
    @State private var audioPlayer: AVAudioPlayer?

    
    var body: some View {
        
        ZStack {
            
            if globals.onboardingStep == 1 {
                // ***** Welcome *****
                showContent(
                    header: "Welcome",
                    text:"Thank you for installing qFocus Browser, the app that helps you keep your social media private.",
                    picture: "OnboardingWelcome")
                
                showNavigation()
                
            } else if globals.onboardingStep == 2 {
                // ***** Privacy *****
                showContent(
                    header: "Privacy",
                    text:"Your privacy is important, \n and it is all that matters to me.",
                    picture: "OnboardingWelcome")
                
                showNavigation()
                
            } else if globals.onboardingStep == 3 {
                // ***** Setup Guide: Access to photos *****
                showContent(
                    header: "Photos Access",
                    text:"Allowing this app full access to your photos is no privacy risk, because this app is not processing them in any way. They are only used to pass them on to the sites when you upload a specifict picuture.",
                    picture: "OnboardingWelcome")
                
                RequestPhotosAccess()
                
                showNavigation()
                
            } else if globals.onboardingStep == 4 {
                // ***** Add First Site
                showContent(
                    header: "First Site",
                    text:"Setup your first site here. You can modify or add it later in the settings. \n \n",
                    picture: "")
                
                FirstSite()
                
                showNavigation()
                
            } else if globals.onboardingStep == 5 {
                // ***** Done *****
                showContent(
                    header: "All Done",
                    text:"Enjoy using the qFocus Browser App!",
                    picture: "OnboardingWelcome")
                
                showNavigation()
                
            }
        }
    }
    
}





#Preview {

    let globals = GlobalVariables()

    globals.onboardingStep = 1
    globals.onboardingFirstSiteOK = false

    return ContentView()
        .environmentObject(globals)
        .modelContainer(for: [sitesStorage.self, settingsStorage.self])
}



