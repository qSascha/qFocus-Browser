//
//  iOSoptionsEditSite.swift
//  qFocus Browser
//
//
import SwiftUI
import UIKit



struct iOSEditSite: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: OptionsEditSiteVM
    @FocusState private var isNameFieldFocused: Bool
    @State private var siteToEdit: SitesStorage
    @State private var debounceTimer: Timer?



    init(editSite: SitesStorage?, sitesRepo: SitesRepo) {
        _viewModel = StateObject(wrappedValue: OptionsEditSiteVM(editSite: editSite, sitesRepo: sitesRepo))
        _siteToEdit = State(initialValue: editSite ?? SitesStorage())
    }
  
    
    var body: some View {
        // Form Fields
        Form {
            Section {
                // Name Field
                HStack {
                    Text("optionsEdit.site.name")
                        .frame(width: 50, alignment: .leading)
                    TextField("", text: $viewModel.tempName)
                        .focused($isNameFieldFocused)
                        .onChange(of: viewModel.tempName) { _, newValue in
                            debounceTimer?.invalidate()
                            debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { _ in
                                Task { @MainActor in
                                    if viewModel.isNewSite || viewModel.tempURL == "" {
                                        viewModel.tempURL = "https://\(newValue.lowercased()).com"
                                        viewModel.fetchFavicon(for: viewModel.tempURL)
                                    }
                                }
                            }
                        }
                    
                    // Favicon Display
                    Spacer()
                    if let image = viewModel.faviconImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        Image(systemName: "globe")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.gray)
                    }
                }
                
                // URL Field
                HStack {
                    Text("optionsEdit.site.Link")
                        .frame(width: 50, alignment: .leading)
                    TextField("", text: $viewModel.tempURL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .onChange(of: viewModel.tempURL) { _, newValue in
                            debounceTimer?.invalidate()
                            debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { _ in
                                Task { @MainActor in
                                    viewModel.fetchFavicon(for: newValue)
                                }
                            }
                        }
                }
            }
            header: {
                Text(viewModel.isNewSite ? "optionsEdit.newSite.header" : "optionsEdit.site.header")
            }
            footer: {
                Text("optionsEdit.site.footer")
            }
            .onAppear {
                // Focus on name field for new sites
                isNameFieldFocused = viewModel.isNewSite
                
                // Load favicon if URL is provided
                if !viewModel.tempURL.isEmpty && viewModel.tempURL != "https://" {
                    viewModel.fetchFavicon(for: viewModel.tempURL)
                }
            }
            

            // Ad Blocker
            Section {
                Toggle("optionsAdvanced.enableAdBlocker.toggle", isOn: $viewModel.enableAdBlocker)
                    .onChange(of: viewModel.enableAdBlocker) { _, newValue in
                    }
            }
            header: {
                Text("optionsAdvanced.enableAdBlocker.header")
            } footer: {
                Text("optionsAdvanced.enableAdBlocker.footer")
            }
            

            // Desktop Site
            Section {
                Toggle("optionsAdvanced.desktopSite.toggle", isOn: Binding(
                    get: { viewModel.requestDesktop },
                    set: { newValue in
                        // Save changes
                        viewModel.requestDesktop = newValue
                    }
                ))
            }
            header: {
                Text("optionsAdvanced.desktopSite.header")
            } footer: {
                Text("optionsAdvanced.desktopSite.footer")
            }
            

            // GreasyMonkey
            Section {
                Toggle("optionsAdvanced.enableGreasy.toggle", isOn: $viewModel.enableGreasy)
                    .onChange(of: viewModel.enableGreasy) { _, newValue in
                    }
            }
            header: {
                Text("optionsAdvanced.enableGreasy.header")
            } footer: {
                Text("optionsAdvanced.enableGreasy.footer")
            }



        }
        .navigationTitle(viewModel.isNewSite ? Text("optionsEdit.title.addSite") : Text(viewModel.tempName))
        .toolbar {
            if !viewModel.isNewSite {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(role: .destructive) {
                        viewModel.tempName = ""
                        dismiss()
                        
                    } label: {
                        Text("Delete")
                    }
                }
            }
        }
        .onDisappear{
            viewModel.saveData()
        }
    }
    
}
