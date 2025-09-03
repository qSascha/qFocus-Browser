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
                HStack {
                    Image("Options-AdBlocking")
                        .resizable()
                        .frame(width: viewModel.iconSize, height: viewModel.iconSize)
                    Text("options.settings.NavigationAdBlocking")
                    
                    Spacer()
                    
                    Toggle("", isOn: viewModel.isAdBlockEnabled)
                }
            }

            // Update frequency
            if viewModel.isAdBlockEnabled.wrappedValue {
                Section {
                    
                    Picker("adblock.update.frequency", selection: viewModel.adBlockUpdateFrequency) {
                        Text("adblock.update.disabled").tag(Int16(0))
                        Text("adblock.update.always").tag(Int16(1))
                        Text("adblock.update.daily").tag(Int16(2))
                        Text("adblock.update.weekly").tag(Int16(3))
                        Text("adblock.update.monthly").tag(Int16(4))
                    }
                }
            }
            
            if viewModel.isAdBlockEnabled.wrappedValue {
                HStack {
                    Spacer()
                    VStack {
                        Text("adblock.lastupdate.label")

                        if viewModel.adBlockUC.updatingFilters   || viewModel.isUpdating {
                            Text("adblock.updatingnow")
                                .font(.caption)
                        } else {
                            Text(viewModel.lastUpdateDate())
                                .font(.caption)
                        }

                        Button(action: {
                            Task {
                                viewModel.isUpdating = true
                                await viewModel.updateNow()
                            }
                        }) {
                            Text("adblock.updatenow.button")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(8)
                                .shadow(radius: 2)
                        }
                    }
                    Spacer()
                }
            }


            // Ad Block Lists
            Section {
                if viewModel.isAdBlockEnabled.wrappedValue {
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
        .onAppear() {
            Collector.shared.save(event: "Viewed", parameter: "Options-AdBlocker")
        }
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
                    Image("AdBlocking-\(filter.filterID)")
                        .resizable()
                        .frame(
                            width: filter.filterID.prefix(5) == "langu" ? viewModel.iconSize : viewModel.iconSize,
                            height: filter.filterID.prefix(5) == "langu" ? viewModel.iconSize * 0.75 : viewModel.iconSize
                        )
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
            .onAppear() {
                Collector.shared.save(event: "Viewed", parameter: "Options-AdBlock-Explanation")
            }
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
