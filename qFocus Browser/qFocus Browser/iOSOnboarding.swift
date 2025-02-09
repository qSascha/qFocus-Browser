//
//  iOSOnboarding.swift
//  qFocus Browser
//
//  Created by Sascha on 2024-12-21.
//

import SwiftUI
import SwiftData
import Photos







struct iOSOnboarding: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var currentStep = 1
    @State private var siteName = ""
    @State private var siteURL = ""
    @State private var faviconImage: UIImage?
    @State private var debounceTimer: Timer?
    
    // First site validation
    @State private var isFirstSiteValid = false
    @FocusState private var isNameFieldFocused: Bool
    
    private let totalSteps = 6
    
    @Query(sort: \adBlockFilters.sortOrder) var adBlockLists: [adBlockFilters]
    @State private var showingExplanation: adBlockFilters?



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
                        
//                        Spacer(minLength: 50)
                    }
                }
                
                // Navigation
                navigationButtons
                    .padding()
//                    .background(Color(UIColor.systemBackground))
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

        case 1:   // MARK: Welcome
            ZStack{
                VStack(spacing: 60) {
                    Text("Thank you for installing qFocus Browser, the app that helps you keep your social media private.")
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

        case 2:   // MARK: Privacy
            ZStack{
                VStack(spacing: 60) {
                    Text("Your privacy is important, and it is all that matters to me.")
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
            
        case 3:   // MARK: Photos Access
            ZStack{
                VStack(spacing: 30) {
                    Text("Allowing this app full access to your photos is no privacy risk, because this app is not processing them in any way. They are only used to pass them on to the sites when you upload a specific picture.")
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                    
//                    Spacer()

                    Button("Grant Photos Access") {
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
            
        case 4:   // MARK: First Site
            FirstSiteView(
                siteName: $siteName,
                siteURL: $siteURL,
                faviconImage: $faviconImage,
                isValid: $isFirstSiteValid,
                isNameFieldFocused: _isNameFieldFocused
            )
            
        case 5: //MARK: AdBlock Selection
            AdBlockListSelector(
                adBlockLists: adBlockLists,
                showingExplanation: $showingExplanation
            )

            
        case 6:   // MARK: Done
            ZStack{
                VStack(spacing: 60) {
                    Text("Enjoy using the qFocus Browser App!")
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
        case 1: return "Welcome"
        case 2: return "Privacy"
        case 3: return "Photos Access"
        case 4: return "First Site"
        case 5: return "Ad Blocking"
        case 6: return "Done"
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
                .disabled(currentStep == 4 && !isFirstSiteValid)
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
        let adBlockLists: [adBlockFilters]
        @Binding var showingExplanation: adBlockFilters?
        @Environment(\.modelContext) private var modelContext
        
        var body: some View {
            VStack(alignment: .leading, spacing: 20) {
                Text("Select ad blocking lists from below. The ones pre-selected are the ones with the best impact on your experience.\nNote: Click on the name of a list to learn more about it.")
                    .padding(.bottom)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(adBlockLists) { filter in
                            HStack {
                                // List Name and Info Button
                                Button(action: {
                                    showingExplanation = filter
                                }) {
                                    HStack {
                                        Text(filter.identName)
                                            .foregroundColor(.primary)
                                        
                                        Spacer()
                                        
                                        if filter.recommended {
                                            Text("Advised")
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
                                    get: { filter.enabled },
                                    set: { newValue in
                                        filter.enabled = newValue
                                        try? modelContext.save()
                                    }
                                ))
                                .labelsHidden()
                            }
/*
                            HStack {
                                Toggle(isOn: Binding(
                                    get: { filter.enabled },
                                    set: { newValue in
                                        filter.enabled = newValue
                                        try? modelContext.save()
                                    }
                                )) {
                                    Button(action: {
                                        showingExplanation = filter
                                    }) {
                                        Text(filter.identName)
                                    }
                                }
                            }
                            .padding(.horizontal)
*/
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
                for filter in adBlockLists {
                    if filter.preSelectediOS {
                        filter.enabled = true
                        try? modelContext.save()
                    }
                }
            }
        }
    }

    struct ExplanationView: View {
        let filter: adBlockFilters
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
                        Button("Done") {
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
            if currentStep == 4 {
                saveFirstSite()
            }
            currentStep += 1
        }
    }
    
    private func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "onboardingComplete")
        dismiss()
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
            firstSiteFavIcon: faviconImage?.pngData() ?? Data()
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
                Text("Name")
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
                Text("Link")
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





