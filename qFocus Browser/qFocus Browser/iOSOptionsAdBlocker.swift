//
//  iOSOptionsAdBlocker.swift
//  qFocus Browser
//
//  Created by Sascha on 2025-02-02.
//
import SwiftUI
import SwiftData






//MARK: Ad Block Settings View
struct AdBlockSettingsView: View {
    @Query() var filterSettings: [adBlockFilterSetting]
    
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var settingsData: settingsStorage
    @State private var showingExplanation: AdBlockFilterItem?
    @EnvironmentObject var startViewModel: StartViewModel
    @EnvironmentObject var globals: GlobalVariables
    @EnvironmentObject var collector: Collector

    
    
    
    
    
    var body: some View {
        
        List {

            // Global Ad-Block Toggle
            Section {
                Toggle("adblock.enable.toggle", isOn: $settingsData.enableAdBlock)
                    .tint(.blue)
                    .onChange(of: settingsData.enableAdBlock) {
                        try? modelContext.save()
                    }
            }
            
            if settingsData.enableAdBlock {
                HStack {
                    Spacer()
                    
                    VStack {
                        Text("adblock.lastupdate.label")
                        Text(settingsData.adBlockLastUpdate?.formatted(date: .abbreviated, time: .omitted) ?? "never")
                            .font(.caption)
                        
                        Button(action: {
                            Task {
                                // Force update with forceUpdate parameter set to true
                                try await startViewModel.initializeBlocker(
                                    settings: settingsData,
                                    filterSettings: filterSettings,
                                    modelContext: modelContext,
                                    forceUpdate: true
                                )
                            }
                        }) {
                            Text("adblock.updatenow.button")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.accentColor)
                                .cornerRadius(8)
                                .shadow(radius: 2)
                        }
                    }
                    Spacer()
                }
            }
            
            // Ad Block Lists
            Section {
                
                if settingsData.enableAdBlock {
                    ForEach(reorderedAdBlockList()) { filter in
                        AdBlockListRow(filter: filter)
                    }
                } else {
                    Text("adblock.message.disabled")
                        .foregroundColor(.gray)
                        .italic()
                }
            } header: {
                Text("adblock.section.header")
            }
        }
        .navigationTitle("adblock.header")
        .onAppear() {
            collector.save(event: "Viewed", parameter: "Ad Blocking")
        }
        .onDisappear {
            Task {
                // Toggle with false to remove all existing rules.
                await startViewModel.toggleBlocking(isEnabled: false, filterSettings: filterSettings)
                
                if settingsData.enableAdBlock {
                    // Rebuild only for currently enabled filters
                    try await startViewModel.initializeBlocker(
                        settings: settingsData,
                        filterSettings: filterSettings,
                        modelContext: modelContext
                    )
                }
            }
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







//MARK: Ad Block List Row
struct AdBlockListRow: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingExplanation = false
    @Query private var filterSettings: [adBlockFilterSetting]
    
    let filter: AdBlockFilterItem
    
    var body: some View {
        HStack {
            // List Name and Info Button
            Button(action: {
                showingExplanation = true
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
            
            // Toggle individual ad-block list
            Toggle("", isOn: Binding(
                get: {
                    filterSettings.first(where: { $0.filterID == filter.filterID })?.enabled ?? filter.preSelectediOS
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
        .sheet(isPresented: $showingExplanation) {
            ExplanationView(filter: filter)
                .presentationDetents([.medium])
        }
    }
}






//MARK: Explanation View
struct ExplanationView: View {
    @Environment(\.dismiss) private var dismiss
    let filter: AdBlockFilterItem
    
    var body: some View {

        NavigationStack {
            
                VStack(alignment: .leading, spacing: 6) {

                    if filter.preSelectediOS {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                            Text("adblock.label.advised")
                                .font(.callout)
                                .foregroundColor(.green)
                            Spacer()
                        }
                        .padding()
                    }

                    Text(filter.explanation)
                        .padding()
                    
                    Spacer()
                    
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

    }
}





