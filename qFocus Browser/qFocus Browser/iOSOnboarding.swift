//
//  iOSOnboarding.swift
//  qFocus Browser
//
//  Created by Sascha on 2024-12-21.
//

import SwiftUI
import SwiftData
import Photos
import LocalAuthentication







struct iOSOnboarding: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var collector: Collector

    @State private var currentStep = 1
    @State private var siteName = ""
    @State private var siteURL = ""
    @State private var faviconImage: UIImage?
    @State private var debounceTimer: Timer?
    
    // First site validation
    @State private var isFirstSiteValid = false
    @FocusState private var isNameFieldFocused: Bool
    
    @State private var stepFirstSite = 5
    private let totalSteps = 7
    
    @State private var showingExplanation: AdBlockFilterItem?

    @EnvironmentObject var globals: GlobalVariables



    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Content
                ScrollView {
                    VStack(spacing: 30) {
                        // Header
                        Text(headerForStep)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                            .padding(.top, 30)

                        Spacer()

                        // Main Content
                        contentForStep
                            .padding(.horizontal, 20)
                        
                    }
                }
                
                // Navigation
                navigationButtons
                    .padding()
                    .background(Color(.qBlueLight))
                    .shadow(radius: 2)
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Step Content
    
    @ViewBuilder
    private var contentForStep: some View {
        switch currentStep {

        case 1:   // MARK: Case 1
            ZStack{
                VStack(spacing: 60) {
                    Text("onboarding.010welcome.text")
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                    
                    Spacer()
                }

                VStack(spacing: 60) {
                    Spacer(minLength: 200)
                    
                    Image("OnboardingWelcome")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                    
                }
            }

        case 2:   // MARK: Case 2
            ZStack{
                VStack(spacing: 60) {
                    Text("onboarding.020privacy.text")
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                    
                    Spacer()
                }

                VStack(spacing: 60) {
                    Spacer(minLength: 200)
                    
                    Image("OnboardingPrivacy")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 150)
                    
                }
            }
            
        case 3:   // MARK: Case 3
            ZStack{
                VStack(spacing: 30) {
                    Text("onboarding.030faceid.text")
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                    
                    Button("onboarding.030faceid.button") {
                        enableFaceID()
                    }
                    .buttonStyle(.borderedProminent)

                    Spacer()
                }

                VStack(spacing: 60) {
                    Spacer(minLength: 200)
                    
                    Image(systemName: "faceid")
                        .font(.system(size: 150))
                        .foregroundColor(.blue)

                }
            }
            
        case 4:   // MARK: Case 4
            ZStack{
                VStack(spacing: 30) {
                    Text("onboarding.040photos.text")
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                    
                    Button("onboarding.040photos.button") {
                        requestPhotoAccess()
                    }
                    .buttonStyle(.borderedProminent)

                    Spacer()
                }

                VStack(spacing: 60) {
                    Spacer(minLength: 200)
                    
                    Image("OnboardingPhotos")
                        .resizable()
                        .frame(width: 250, height: 140)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                    
                }
            }
            
        case 5:   // MARK: Case 5
            FirstSiteView(
                siteName: $siteName,
                siteURL: $siteURL,
                faviconImage: $faviconImage,
                isValid: $isFirstSiteValid,
                isNameFieldFocused: _isNameFieldFocused
            )
            
        case 6: //MARK: Case: 6
            AdBlockListSelector(
                adBlockLists: globals.adBlockList,
                showingExplanation: $showingExplanation
            )

            
        case 7:   // MARK: Case 7
            ZStack{
                VStack(spacing: 60) {
                    Text("onboarding.070done.text")
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                    
                    Spacer()
                }

                VStack(spacing: 60) {
                    Spacer(minLength: 200)
                    
                    Image(systemName: "checkmark.bubble.rtl")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 200)
                        .foregroundColor(.blue)

                }
            }
            
        default:
            EmptyView()
        }
    }
    
    private var headerForStep: String {
        switch currentStep {
        case 1: return String(localized: "onboarding.010welcome.header")
        case 2: return String(localized: "onboarding.020privacy.header")
        case 3: return String(localized: "onboarding.030faceID.header")
        case 4: return String(localized: "onboarding.040photos.header")
        case 5: return String(localized: "onboarding.050firstsite.header")
        case 6: return String(localized: "onboarding.060adblock.header")
        case 7: return String(localized: "onboarding.070done.header")
        default: return ""
        }
    }
    

    // MARK: - Navigation
    private var navigationButtons: some View {
        HStack {
            if currentStep > 1 {
                Button(action: previousStep) {
                    Image(systemName: "arrow.left")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
            
            if currentStep < totalSteps {
                Button(action: nextStep) {
                    Image(systemName: "arrow.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                        .foregroundColor(.white)
                }
                .disabled(currentStep == stepFirstSite && !isFirstSiteValid)
            } else {
                Button(action: completeOnboarding) {
                    Image(systemName: "checkmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30)
                        .foregroundColor(.white)
                }
            }
        }
        .padding(.horizontal, 20)
    }
    


    //MARK: AdBlock Selector
    struct AdBlockListSelector: View {
        @StateObject var globals = GlobalVariables()
        let adBlockLists: [AdBlockFilterItem]
        @Binding var showingExplanation: AdBlockFilterItem?
        @Environment(\.modelContext) private var modelContext
        @Query private var filterSettings: [adBlockFilterSetting]
        
        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text("onboarding.060adblock.text")
                    .padding(.bottom)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(reorderedAdBlockList()) { filter in
                            HStack {
                                // List Name and Info Button
                                Button(action: {
                                    showingExplanation = filter
                                }) {
                                    HStack {
                                        Text(filter.identName)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        if filter.preSelectediOS {
                                            Text("adblock.label.advised")
                                                .font(.caption)
                                                .foregroundColor(.green)
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .stroke(Color.green, lineWidth: 1)
                                                )
                                        }
                                    }
                                }

                                // Toggle
                                Toggle("", isOn: Binding(
                                     get: {
                                         if let setting = filterSettings.first(where: { $0.filterID == filter.filterID }) {
                                             return setting.enabled
                                         } else {
                                             return filter.preSelectediOS
                                         }
                                     },
                                     set: { newValue in
                                         if let existingSetting = filterSettings.first(where: { $0.filterID == filter.filterID }) {
                                             existingSetting.enabled = newValue
                                         } else {
                                             let newSetting = adBlockFilterSetting(filterID: filter.filterID, enabled: newValue)
                                             modelContext.insert(newSetting)
                                         }
                                         try? modelContext.save()
                                     }
                                 ))
                                .labelsHidden()

                            }
                            
                        }
                    }
                }
            }
            .padding()
            .sheet(item: $showingExplanation) { filter in
                ExplanationView(filter: filter)
            }
            .onAppear {
                // Set initial states based on preSelectedIOS
                // Initialize all filter settings if they don't exist
                for filter in reorderedAdBlockList() {
                    // Check if setting already exists
                    if !filterSettings.contains(where: { $0.filterID == filter.filterID }) {
                        // Create new setting with preSelectediOS as initial state
                        let newSetting = adBlockFilterSetting(
                            filterID: filter.filterID,
                            enabled: filter.preSelectediOS
                        )
                        modelContext.insert(newSetting)
                    }
                }
                try? modelContext.save()
            }
        }
        

        
        private func reorderedAdBlockList() -> [AdBlockFilterItem] {
            let deviceLanguage = String(Locale.preferredLanguages[0].prefix(2))
            var reorderedList = globals.adBlockList
            if let index = reorderedList.firstIndex(where: { $0.languageCode == deviceLanguage }) {
                var languageItem = reorderedList.remove(at: index)
                languageItem.preSelectediOS = true
                reorderedList.insert(languageItem, at: 5)
            }
            return reorderedList
        }
        
    }


    
    

    struct ExplanationView: View {
        let filter: AdBlockFilterItem
        @Environment(\.dismiss) private var dismiss
        
        var body: some View {
            NavigationView {
                ScrollView {
                    Text(filter.explanation)
                        .padding()
                }
                .navigationTitle(filter.identName)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("general.done") {
                            dismiss()
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }


    

    // MARK: - Actions
    private func previousStep() {
        withAnimation {
            currentStep -= 1
        }
    }
    
    private func nextStep() {
        withAnimation {
            if currentStep == stepFirstSite {
                saveFirstSite()
            }
            currentStep += 1
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "onboardingComplete")
        collector.save(event: "Onboarding", parameter: "Complete")
        dismiss()
    }
    



    private func enableFaceID() {
        let context = LAContext()
        var error: NSError?
        
        // First check if device can use biometric authentication
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // Attempt to authenticate to confirm enrollment
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "onboarding.030faceID.localizedReason"
            ) { success, authError in
                // Update the settings on the main thread
                DispatchQueue.main.async {
                    if success {
                        // Successfully authenticated, enable Face ID in settings
                        globals.faceIDEnabled = true
                    }
                }
            }
        } else {
            // Device doesn't support Face ID
            globals.faceIDEnabled = false
        }
    }
    



    private func requestPhotoAccess() {
        PHPhotoLibrary.requestAuthorization { status in
            // Handle the authorization status
        }
    }
    



    private func saveFirstSite() {
        // Implementation of saving the first site
        reinitializeData(
            modelContext: modelContext,
            firstSiteName: siteName,
            firstSiteURL: siteURL,
            firstSiteFavIcon: faviconImage?.pngData() ?? Data(),
            faceIDEnabled: globals.faceIDEnabled
        )
    }
}





// MARK: - First Site View
struct FirstSiteView: View {
    @Binding var siteName: String
    @Binding var siteURL: String
    @Binding var faviconImage: UIImage?
    @Binding var isValid: Bool
    @FocusState var isNameFieldFocused: Bool
    
    @State private var debounceTimer: Timer?
    
    var body: some View {
        VStack(spacing: 20) {
            // Name Field
            HStack {
                Text("onboarding.050firstsite.formName")
                    .frame(width: 50, alignment: .leading)
                TextField("", text: $siteName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($isNameFieldFocused)
                    .onChange(of: siteName) { _, newValue in
                        updateURL(from: newValue)
                    }
            }
            
            // URL Field
            HStack {
                Text("onboarding.050firstsite.formLink")
                    .frame(width: 50, alignment: .leading)
                TextField("", text: $siteURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                    .onChange(of: siteURL) { _, newValue in
                        updateFavicon(for: newValue)
                    }
            }
            
            // Favicon
            if let image = faviconImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 32)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding()
        .onAppear {
            isNameFieldFocused = true
        }
    }
    
    private func updateURL(from name: String) {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { _ in
            siteURL = "https://\(name.lowercased()).com"
            updateFavicon(for: siteURL)
            isValid = !name.isEmpty
        }
    }
    
    private func updateFavicon(for url: String) {
        guard !url.isEmpty else { return }
        let fqdn = url.replacingOccurrences(of: "https://", with: "")
                     .replacingOccurrences(of: "http://", with: "")
        
        guard let iconURL = URL(string: "https://icons.duckduckgo.com/ip3/\(fqdn).ico") else { return }
        
        URLSession.shared.dataTask(with: iconURL) { data, _, _ in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.faviconImage = image
                }
            }
        }.resume()
    }
}




//MARK: Re-Initialize Data
func reinitializeData(modelContext: ModelContext, firstSiteName: String, firstSiteURL: String, firstSiteFavIcon: Data, faceIDEnabled: Bool) {
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
        let adBlockDescriptor = FetchDescriptor<adBlockFilterSetting>()
        let existingAdBlock = try modelContext.fetch(adBlockDescriptor)
        for filter in existingAdBlock {
            modelContext.delete(filter)
        }
        
        // Delete GreasyFork scripts
        let greasyForkDescriptor = FetchDescriptor<greasyScriptSetting>()
        let existingGreasyFork = try modelContext.fetch(greasyForkDescriptor)
        for greasyItem in existingGreasyFork {
            modelContext.delete(greasyItem)
        }

        try modelContext.save()
    } catch {
        // Handle error appropriately for your app
        print("Error deleting existing records: \(error)")
    }
    
    


    // Initialize with default values
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
    
    



    // Save faceIDEnalbed value to settings
    let settingsDescriptor = FetchDescriptor<settingsStorage>()

    do {
        if let settings = try modelContext.fetch(settingsDescriptor).first {
            settings.faceIDEnabled = faceIDEnabled
            
            try modelContext.save()
        } else {
            print("ERROR: No record found for updating.")
        }
    } catch {
        print("ERROR: Updating \"First Site\" failed: \(error.localizedDescription)")
    }


}





