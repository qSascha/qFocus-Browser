//
//  iPadOptions.swift
//  qFocus Browser
//
//
import CoreData
import SwiftUI
import UIKit
import FactoryKit
import Combine

/*
struct Site: Identifiable {
    let id = UUID()
    var name: String
}



class NavigationStateManager: ObservableObject {
    @Published var path = NavigationPath()
}


enum NavTarget: Hashable {
    case greasyOption
    case greasyWiz1
    case greasyWiz2
    case greasyEdit(scriptObject: GreasyScriptStorage)
}
*/


struct iPadOptions: View {
    @InjectedObject(\.optionsVM) var viewModel: OptionsVM
    @InjectedObject(\.greasyRepo) var greasyRepo
    @InjectedObject(\.sitesRepo) var sitesRepo
    @Environment(\.dismiss) private var dismiss

    @StateObject var nav = NavigationStateManager()
    @State private var showSwedish = true
    @State private var swedishOpacity = 1.0
    @State private var swedishTimer: Timer? = nil
    @State private var editMode: EditMode = .inactive

    
    
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            
            NavigationStack(path: $nav.path) {
                
                List {
                    
                    Section {
                        
                        NavigationLink(destination: iPadPromotion()) {
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
                            NavigationLink(destination: iPadEditSite(
                                editSite: site,
                                sitesRepo: viewModel.sitesRepo
                            )) {
                                websiteRowContent(for: site)
                            }
                        }
                        .onMove(perform: moveSite)
                        
                        // Display "Add website" row if we have room for more sites
                        if viewModel.canAddSite() {
                            NavigationLink(destination: iPadEditSite(editSite: nil, sitesRepo: viewModel.sitesRepo)) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                        .resizable()
                                        .frame(width: viewModel.iconSize, height: viewModel.iconSize)
                                        .foregroundColor(.blue)
                                    
                                    Text("options.websites.add")
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
                    
                    // Temp Disable External Browser Section
                    disableExternalBrowser()
                    
                    // Settings Section
                    iPadOptionsViewSettings()
                    
                }
                .navigationDestination(for: NavTarget.self) { destination in
                    switch destination {
                    case .greasyOption:
                        iPadGreasySettings()
                        
                    case .greasyWiz1:
                        iPadGreasyWizard1()
                        
                    case .greasyWiz2:
                        iPadGreasyWizard2(viewModel: GreasyBrowserVM(url: URL(string:"https://greasyfork.org")!) )
                        
                    case .greasyEdit(let scriptObject):
                        iPadOptionsGreasyEdit(scriptObject: scriptObject, greasyRepo: greasyRepo, sitesRepo: sitesRepo)
                        
                    }
                }
                .navigationTitle("options.header.text")
                .navigationBarItems(trailing: EditButton())
                .environment(\.editMode, $editMode)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("general.done") {
                            viewModel.save()
                            dismiss()
                        }
                    }
                }
                .onAppear {
                    // Start timer on first appearance only
                    if swedishTimer == nil {
                        swedishTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
                            DispatchQueue.main.async {
                                withAnimation {
                                    swedishOpacity = 0
                                }
                                // Remove the view after the fade completes (1 second here)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                    showSwedish = false
                                    swedishTimer?.invalidate()
                                    swedishTimer = nil
                                }
                            }
                        }
                    }
                }
                .sheet(item: $viewModel.externalURL, onDismiss: {
                    viewModel.externalURL = nil
                }) { identifiable in
                    ExternalBrowserView(viewModel: ExternalBrowserVM(url: identifiable.url))
                }
                
            }
            .environmentObject(nav)
            .onAppear() {
                Collector.shared.save(event: "Viewed", parameter: "Options")
            }

            if showSwedish {
                ItIsSwedish(textSize: 18, bubbleWidth: 100, bubbleHeight: 90, offsetX: 200, offsetY: 30, textOffsetX: 0, textOffsetY: -10)
                    .opacity(swedishOpacity)
                    .animation(.easeInOut(duration: 1), value: swedishOpacity)
            }

            
        }
    }

    
    
    //MARK: Temp Disable External Browser
    struct disableExternalBrowser: View {
        @InjectedObject(\.optionsVM) var viewModel: OptionsVM

        let iconSize: CGFloat = 30

        var body: some View {
            Section {

                Button(action: {
                    viewModel.disableExternalBrowser()
                }) {
                    HStack {
                        Image("3rd Party Links")
                            .resizable()
                            .frame(width: viewModel.iconSize, height: viewModel.iconSize)

                        if viewModel.disableEBCountdownActive {
                            Text("options.disableEB.textDisabledEB")
                            
                            Spacer()

                            Image(systemName: "exclamationmark.triangle.fill")
                                .resizable()
                                .frame(width: viewModel.iconSize * 0.75, height: viewModel.iconSize * 0.75)
                                .foregroundColor(.red)
                                .padding(.horizontal, 6)

                            Text(viewModel.disableEBCountdownText)
                                .font(.caption)
                                .foregroundColor(.gray)

                        } else  {
                            Text("options.disableEB.textEnabledEB")
                            
                            Spacer()

                            Image(systemName: "exclamationmark.triangle")
                                .resizable()
                                .frame(width: viewModel.iconSize * 0.75, height: viewModel.iconSize * 0.75)
                                .foregroundColor(.green)
                                .padding(.horizontal, 6)

                            Text("options.disableEB.enabled")
                                .font(.caption)
                                .foregroundColor(.gray)

                        }
                    }
                }
                .buttonStyle(.plain)
                .listRowBackground(
                    // Add pulsing background when countdown is active, otherwise use default
                    Group {
                        if viewModel.disableEBCountdownActive {
                            iPadPulsingListRowBackground(color: .red)
                        } else {
                            Color(UIColor.systemBackground)
                        }
                    }
                )

            } header: {
                Text("options.disableEB.header")
                    .padding(.top, 30)

            } footer: {
                Text("options.disableEB.footer")
                    .padding(.bottom, 30)
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
    struct iPadOptionsViewSettings: View {
        @InjectedObject(\.optionsVM) var viewModel: OptionsVM
        @EnvironmentObject var nav: NavigationStateManager
        
        let iconSize: CGFloat = 30
        
        
        
        var body: some View {
            Section {

                HStack {
                    Image("Options-FaceID")
                        .resizable()
                        .frame(width: viewModel.iconSize, height: viewModel.iconSize)

                    Toggle("options.settings.toggleEnableFaceID", isOn: $viewModel.faceIDEnabled)
                }
                
                Button {
                    viewModel.photoLibraryRequestAccess()
                } label: {
                    HStack {
                        Image("Options-PhotoLibrary")
                            .resizable()
                            .frame(width: viewModel.iconSize, height: viewModel.iconSize)

                        Text("options.settings.PhotoLibrary")
                        
                        Image(systemName: "arrow.up.right.square")
                            .resizable()
                            .frame(width: viewModel.iconSize * 0.5, height: viewModel.iconSize * 0.5)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 6)
                        Spacer()
                        
                            
                        Image(systemName: viewModel.alPhotoLibraryImage)
                            .resizable()
                            .frame(width: viewModel.iconSize * 0.75, height: viewModel.iconSize * 0.75)
                            .foregroundColor(viewModel.alPhotoLibraryColor)
                            .padding(.horizontal, 6)
                        Text(viewModel.alPhotoLibraryText)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .buttonStyle(.plain)
                
                NavigationLink(destination: iPadAdBlockSettings()) {
                    HStack {
                        Image("Options-AdBlocking")
                            .resizable()
                            .frame(width: viewModel.iconSize, height: viewModel.iconSize)
                        Text("options.settings.NavigationAdBlocking")

                        Spacer()

                        Image(systemName: "shield.fill")
                            .resizable()
                            .frame(width: viewModel.iconSize * 0.5, height: viewModel.iconSize * 0.75)
                            .foregroundColor(viewModel.isAdBlockEnabled ? .green : .gray)
                            .padding(.horizontal, 6)

                        if viewModel.isAdBlockEnabled {
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
                HStack {
                    Image("Options-GreasyFork")
                        .resizable()
                        .frame(width: viewModel.iconSize, height: viewModel.iconSize)
                    
                    NavigationLink(value: NavTarget.greasyOption) {
                        Text("options.settings.NavigationGreasy")
                    }
                }

                HStack {
                    Image("Options-QnA")
                        .resizable()
                        .frame(width: viewModel.iconSize, height: viewModel.iconSize)
                    
                    NavigationLink(destination: iPadOptionsQnA()) {
                        Text("options.settings.navigationQnA")
                    }
                }

                HStack {
                    Image("Options-About")
                        .resizable()
                        .frame(width: viewModel.iconSize, height: viewModel.iconSize)
                    
                    NavigationLink(destination: iPadAbout()) {
                        Text("options.settings.navigationAbout")
                    }
                }
            } header: {
                Text("options.settings.header")
            } footer: {
                Text("general.version \(appVersion)")
            }
        }
    }
    
    
}



// MARK: - Pulsing List Row Background
struct iPadPulsingListRowBackground: View {
    let color: Color
    @State private var isPulsing = false
    
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(color.opacity(isPulsing ? 0.2 : 0.7))
            .onAppear {
                withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            }
            .onDisappear {
                isPulsing = false
            }
    }
}

#Preview {
    iPadOptions()
}
