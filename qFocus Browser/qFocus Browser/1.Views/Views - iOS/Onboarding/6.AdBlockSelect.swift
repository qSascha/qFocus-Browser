//
//  AdBlockSelect.swift
//  qFocus Browser
//
//
import SwiftUI
import FactoryKit



struct AdBlockSelect: View {
    @InjectedObject(\.adBlockSelectVM) var viewModel: AdBlockSelectVM
    
    @State private var showingExplanation: AdBlockFilterDisplayItem?



    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("onboarding.060adblock.text")
                .padding(.bottom)

            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    ForEach(viewModel.displayItems) { filter in
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
                                get: { filter.enabled },
                                set: { newValue in
                                    filter.enabled = newValue
                                    viewModel.toggle(filterID: filter.filterID, to: newValue)
                                }
                            ))
                            .labelsHidden()
                        }
                    }
                    Spacer()
                        .frame(height: 80)
                        .fixedSize()

                }
            }
        }
        .padding()
        .sheet(item: $showingExplanation) { filter in
            ABSExplanationView(filter: filter)
                .presentationDetents([.medium])
        }
        .onDisappear {
            viewModel.saveCurrentSettings()
        }

    }
}


