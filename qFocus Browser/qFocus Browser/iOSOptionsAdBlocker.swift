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
    @Query(sort: \adBlockFilters.sortOrder) var adBlockLists: [adBlockFilters]

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var settingsData: settingsStorage
    @State private var showingExplanation: adBlockFilters?
    @ObservedObject var viewModel: ContentViewModel




    var body: some View {
        NavigationView {
            List {
                // Global Ad-Block Toggle
                Section {
                    Toggle("Enable Ad-Blocker", isOn: $settingsData.enableAdBlock)
                        .tint(.blue)
                }
                
                // Ad Block Lists
                Section {
                    if settingsData.enableAdBlock {
                        ForEach(adBlockLists) { filter in
                            AdBlockListRow(filter: filter)
                        }
                    } else {
                        Text("Enable Ad-Blocker to select filters")
                            .foregroundColor(.gray)
                            .italic()
                    }
                } header: {
                    Text("Filter Lists")
                }
            }
            .navigationTitle("Ad Blocking")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear {
                Task {
                    // Toggle with false to remove all existing rules.
                    let enabledFilters = adBlockLists.filter { $0.enabled }
                    await viewModel.toggleBlocking(isEnabled: false, enabledFilters: enabledFilters)
                    
                    if settingsData.enableAdBlock {
                        // Rebuild only for currently enabled filters
                        try await viewModel.initializeBlocker(isEnabled: settingsData.enableAdBlock, enabledFilters: enabledFilters)
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
                            Text("This filter list is recommended for most users")
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
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
