//
//  iOSOptions.swift
//  qFocus Browser
//
//
import SwiftUI
import UIKit
import FactoryKit
import Combine


struct Site: Identifiable {
    let id = UUID()
    var name: String
}



struct iOSOptions: View {
    @InjectedObject(\.optionsVM) var viewModel: OptionsVM
    @Environment(\.dismiss) private var dismiss
    
    @State private var editMode: EditMode = .inactive

    
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    
                    NavigationLink(destination: iOSPromotion()) {
                        HStack {
                            Image(uiImage: UIImage(named: "Promotion-BMC-logo")!)
                                .resizable()
                                .frame(width: viewModel.iconSize * 1.1, height: viewModel.iconSize*1.1)
                                .cornerRadius(viewModel.iconSize*1.3/2)
                            
                            Text("options.settings.navigationPromotion")
                                .padding(.leading)
                        }
                    }
                }
                
                Section(header: Text("options.websites.header")) {

                    ForEach(viewModel.sites.map { $0 }, id: \.objectID) { site in
                        NavigationLink(destination: iOSEditSite(editSite: site, repo: viewModel.sitesRepo)) {
                            websiteRowContent(for: site)
                        }
                    }
                    .onMove(perform: moveSite)

                    // Display "Add website" row if we have room for more sites
                    if viewModel.canAddSite() {
                        NavigationLink(destination: iOSEditSite(editSite: nil, repo: viewModel.sitesRepo)) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .frame(width: viewModel.iconSize, height: viewModel.iconSize)
                                    .foregroundColor(.blue)
                                
                                Text("Add Website")
                                    .foregroundColor(.blue)
                                    .padding(.leading, 8)
                                
                                Spacer()
                                
                                if viewModel.sites.count > 0 {
                                    // Show how many more sites can be added
                                    let remaining = viewModel.maxSites - viewModel.sitesRepo.getAllSites().count
                                    Text("\(remaining) remaining")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                }

                // Settings Section
                iOSOptionsViewSettings()
                
            }
            .navigationTitle("options.header.text")
            .navigationBarItems(trailing: EditButton())
            .environment(\.editMode, $editMode)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("general.done") {
                        try? viewModel.save()
                        dismiss()
                    }
                }
            }
            .sheet(item: $viewModel.externalURL, onDismiss: {
                viewModel.externalURL = nil
            }) { identifiable in
                ExternalBrowserView(viewModel: ExternalBrowserVM(url: identifiable.url))
            }

        }

    }
    

    
    //MARK: Move Site
    private func moveSite(from source: IndexSet, to destination: Int) {
        viewModel.sites.move(fromOffsets: source, toOffset: destination)
        viewModel.persistSiteOrder()
        // Update NavBar and NavFlowBar
        CombineRepo.shared.updateWebSites.send()
    }
    
    

    //MARK: List Rows View
    @ViewBuilder
    private func websiteRowContent(for site: SitesStorage) -> some View {
        
        HStack {
            // Display site favicon if available
            if let faviconData = site.siteFavIcon,
               let favicon = UIImage(data: faviconData) {
                Image(uiImage: favicon)
                    .resizable()
                    .frame(width: viewModel.iconSize, height: viewModel.iconSize)
                    .clipShape(RoundedRectangle(cornerRadius: viewModel.iconSize/2))
            } else {
                // Fallback icon if favicon is missing
                Image(systemName: "globe")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: viewModel.iconSize, height: viewModel.iconSize)
                    .foregroundColor(.gray)
            }
            
            // Site details
            VStack(alignment: .leading) {
                Text(site.siteName)
                    .font(.headline)
                
                Text(site.siteURL)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.leading, 8)
        }
    }
    
    

    //MARK: Options View Settings
    struct iOSOptionsViewSettings: View {
        @InjectedObject(\.optionsVM) var viewModel: OptionsVM
        
        let iconSize: CGFloat = 30
        
        
        
        var body: some View {
            Section {

                Toggle("options.settings.toggleEnableFaceID", isOn: $viewModel.faceIDEnabled)
                
                NavigationLink(destination: iOSAdBlockSettings()) {
                    HStack {
                        Text("options.settings.NavigationAdBlocking")
                        Image(systemName: "shield.fill")
                            .foregroundColor(viewModel.adBlockUpdateFrequency != 0 ? .green : .gray)
                        
                        Spacer()
                        
                        if viewModel.adBlockUpdateFrequency != 0 {
                            Text("\(viewModel.enabledFilterCount) adblock.activeCounts")
                                .font(.caption)
                            .foregroundColor(.gray)
                        } else {
                            Text("options.settings.adblockLabelDisabled")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                
                NavigationLink(destination: iOSAbout()) {
                    Text("options.settings.navigationAbout")
                }
            } header: {
                Text("options.settings.header")
            } footer: {
                Text("general.version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")")
            }
        }
    }
    
    
}

