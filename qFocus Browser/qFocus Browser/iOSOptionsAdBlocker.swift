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
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var settingsData: settingsStorage
    @State private var showingExplanation: AdBlockFilterItem?
    @EnvironmentObject var startViewModel: StartViewModel
    @EnvironmentObject var globals: GlobalVariables






    var body: some View {

        NavigationView {
            List {
                // Global Ad-Block Toggle
                Section {
                    Toggle("toggle_enable_adblocking".localized, isOn: $settingsData.enableAdBlock)
                        .tint(.blue)
                }
                
                if settingsData.enableAdBlock {
                    HStack {
                        Spacer()
                        
                        VStack {
                            Text("header_last_updated".localized)
                            Text(settingsData.adBlockLastUpdate?.formatted(date: .abbreviated, time: .omitted) ?? "text_never".localized)
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
                                Text("button_update_now".localized)
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
                        ForEach(globals.adBlockList) { filter in
                            AdBlockListRow(filter: filter)
                        }
                    } else {
                        Text("request_enable_ad_blocking_first".localized)
                            .foregroundColor(.gray)
                            .italic()
                    }
                } header: {
                    Text("header_filter_lists".localized)
                }
            }
            .navigationTitle("header_ad_blocking".localized)
            .navigationBarTitleDisplayMode(.inline)
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
                        Text("advised_label".localized)
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
        }
    }
}






//MARK: Explanation View
struct ExplanationView: View {
    @Environment(\.dismiss) private var dismiss
    let filter: AdBlockFilterItem
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(filter.explanation)
                        .padding()
                    
                    if filter.preSelectediOS {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                            Text("advised_text".localized)
                                .font(.callout)
                                .foregroundColor(.green)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(filter.identName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done_button".localized) {
                        dismiss()
                    }
                }
            }
        }
    }
}






/*
import SwiftUI
import SwiftData




//MARK: Ad Block Settings View
struct AdBlockSettingsView: View {
    @Query(sort: \adBlockFilters.sortOrder) var adBlockLists: [adBlockFilters]

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var settingsData: settingsStorage
    @State private var showingExplanation: adBlockFilters?
    @EnvironmentObject var startViewModel: StartViewModel




    var body: some View {

        NavigationView {
            List {
                // Global Ad-Block Toggle
                Section {
                    Toggle("toggle_enable_adblocking".localized, isOn: $settingsData.enableAdBlock)
                        .tint(.blue)
                }
                
                
                if settingsData.enableAdBlock {
                    
                    HStack {
                        Spacer()
                        
                        VStack {
                            Text("header_last_updated".localized)
                            Text(settingsData.adBlockLastUpdate?.formatted(date: .abbreviated, time: .omitted) ?? "text_never".localized)
                                .font(.caption)

                            Button(action: {
                                Task {
                                    let enabledFilters = adBlockLists.filter { $0.enabled }
//                                    await startViewModel.toggleBlocking(isEnabled: false, enabledFilters: enabledFilters)
                                    
                                    // Force update with forceUpdate parameter set to true
                                    try await startViewModel.initializeBlocker(
                                        settings: settingsData,
                                        enabledFilters: enabledFilters,
                                        modelContext: modelContext,
                                        forceUpdate: true
                                    )
                                }
                                
                            }) {
                                Text("button_update_now".localized)
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
                        ForEach(adBlockLists) { filter in
                            AdBlockListRow(filter: filter)
                        }
                    } else {
                        Text("request_enable_ad_blocking_first".localized)
                            .foregroundColor(.gray)
                            .italic()
                    }
                } header: {
                    Text("header_filter_lists".localized)
                }
            }
            .navigationTitle("header_ad_blocking".localized)
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear {
                Task {
                    // Toggle with false to remove all existing rules.
                    let enabledFilters = adBlockLists.filter { $0.enabled }
                    await startViewModel.toggleBlocking(isEnabled: false, enabledFilters: enabledFilters)
                    
                    if settingsData.enableAdBlock {
                        // Rebuild only for currently enabled filters
                        try await startViewModel.initializeBlocker(settings: settingsData, enabledFilters: enabledFilters, modelContext: modelContext)
                    }
                }
            }

        }
    }
}




//MARK: Ad Block List Rows
struct AdBlockListRow: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingExplanation = false
    
    let filter: adBlockFilters
    
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
                    
                    if filter.recommended {
                        Text("advised_label".localized)
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
        .sheet(isPresented: $showingExplanation) {
            ExplanationView(filter: filter)
        }
    }
}


//MARK: Explanation View
struct ExplanationView: View {
    @Environment(\.dismiss) private var dismiss
    let filter: adBlockFilters
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(filter.explanation)
                        .padding()
                    
                    if filter.recommended {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundColor(.green)
                            Text("advised_text".localized)
                                .font(.callout)
                                .foregroundColor(.green)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(filter.identName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("done_button".localized) {
                        dismiss()
                    }
                }
            }
        }
    }
}
*/
