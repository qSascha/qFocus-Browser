//
//  iOSOptionsAdBlocker.swift
//  qFocus Browser
//
//
import SwiftUI
import FactoryKit



// MARK: Ad Block Settings View
struct iOSAdBlockSettings: View {
    @InjectedObject(\.iOSAdBlockSettVM) private var viewModel

    @State private var showingExplanation: AdBlockFilterDisplayItem?

    
    var body: some View {
        List {
            // Global Ad-Block Toggle
            Section {
                Picker("Ad-Block Frequency", selection: viewModel.adBlockUpdateFrequency) {
                    Text("Disabled").tag(Int16(0))
                    Text("Always").tag(Int16(1))
                    Text("Daily").tag(Int16(2))
                    Text("Weekly").tag(Int16(3))
                    Text("Monthly").tag(Int16(4))
                }
                
            }

            if viewModel.isAdBlockEnabled {
                HStack {
                    Spacer()
                    VStack {
                        Text("adblock.lastupdate.label")
                        Text(viewModel.lastUpdateDate())
                            .font(.caption)

                        Button(action: {
                            Task {
                                await viewModel.updateNow()
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
                if viewModel.isAdBlockEnabled {
                    ForEach( viewModel.filterItems, id: \.filterID) { filter in
                        AdBlockListRow(filter: filter) {
                            showingExplanation = filter
                        }
                    }
                } else {
                    Text("adblock.message.disabled")
                        .foregroundColor(.gray)
                        .italic()
                }
            }
        }
        .navigationTitle("adblock.header")
        .sheet(item: $showingExplanation) { filter in
            ExplanationView(filter: filter)
                .presentationDetents([.medium])
        }


    }
}







//MARK: Ad Block List Row
struct AdBlockListRow: View {
    @InjectedObject(\.iOSAdBlockSettVM) private var viewModel

    let filter: AdBlockFilterDisplayItem
    let onExplainTapped: () -> Void


    
    var body: some View {
        HStack {

            // List Name and Info Button
            Button(action: onExplainTapped) {
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
            Toggle("", isOn: viewModel.toggleListItem(for: filter))
                .labelsHidden()
        }

    }
}










struct ExplanationView: View {
    @Environment(\.dismiss) private var dismiss
    let filter: AdBlockFilterDisplayItem



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
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                }
            }
        }
    }
}


