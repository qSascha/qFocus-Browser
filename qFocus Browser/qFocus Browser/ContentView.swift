//
//  ContentView.swift
//  qFocus Browser
//
//  Created by Sascha on 2025-01-25.
//
//
//  qFocus_BrowserApp.swift
//  qFocus Browser
//
//  Created by Sascha on 2025-01-25.
//
import SwiftUI
import SwiftData
import AVFoundation
import WebKit





//MARK: View: Navigation Button
struct NavButton: View {
    @Query() var settingsData: [settingsStorage]

    var actionType: String    // backward, forward, main
    var imageData: Data
    var textStr: String

    var body: some View {

        @Bindable var settingsData = settingsData[0]

        switch actionType {
        case "main":
            if !settingsData.hideMainIcons {
                Image(uiImage: UIImage(data: imageData) ?? UIImage(systemName: "exclamationmark.circle")!)
                    .resizable()
                    .foregroundColor(.blue)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: !settingsData.bigIcons ? 18 : 24, height: !settingsData.bigIcons ? 18 : 24, alignment: .center)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: !settingsData.bigIcons ? 18 : 24
                        )
                    )
            }
           Text(textStr)
               .font(.headline)
               .lineLimit(1)
               .foregroundColor(.blue)
               .frame(alignment: .center)
               .padding(.leading, 5)

        case "previous":
            Image(systemName: "chevron.backward")
                .resizable()
                .foregroundColor(.blue)
                .aspectRatio(contentMode: .fit)
                .frame(width: !settingsData.bigIcons ? 10 : 12, height: !settingsData.bigIcons ? 18 : 20, alignment: .center)

            if !settingsData.hideSideIcons {
                Image(uiImage: UIImage(data: imageData) ?? UIImage(systemName: "exclamationmark.circle")!)
                    .resizable()
                    .foregroundColor(.blue)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: !settingsData.bigIcons ? 18 : 24, height: !settingsData.bigIcons ? 18 : 24, alignment: .center)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: !settingsData.bigIcons ? 18 : 24
                        )
                    )
            }
            
        case "next":
            if !settingsData.hideSideIcons {
                Image(uiImage: UIImage(data: imageData) ?? UIImage(systemName: "exclamationmark.circle")!)
                    .resizable()
                    .foregroundColor(.blue)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: !settingsData.bigIcons ? 18 : 24, height: !settingsData.bigIcons ? 18 : 24, alignment: .center)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: !settingsData.bigIcons ? 18 : 24
                        )
                    )
            }
            Image(systemName: "chevron.forward")
                .resizable()
                .foregroundColor(.blue)
                .aspectRatio(contentMode: .fit)
                .frame(width: !settingsData.bigIcons ? 10 : 12, height: !settingsData.bigIcons ? 18 : 20, alignment: .center)

        default:
            Text("")
        }
        

    }
}





// MARK: Content View
struct ContentView: View {

    private let blockListManager = BlockListManager()
    private var webViewControllers: [ContentBlockingWebViewController] = []

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @Environment(\.modelContext) private var modelContext
    
    @StateObject private var viewModel = ContentViewModel()

    @AppStorage("onboardingComplete") var onboardingComplete: Bool = false
    
    @StateObject var globals = GlobalVariables()
    
    @State private var audioPlayer: AVAudioPlayer?

    @State private var showOptions = false
    
    @Query(
        filter: #Predicate<sitesStorage> { $0.siteName != ""},
        sort: \sitesStorage.siteOrder
    ) var webSites: [sitesStorage]
    
    @Query() var settingsDataArray: [settingsStorage]

    
    
    
    
    var body: some View {
        

//        if true {
        if ( !onboardingComplete) {
            
            Onboarding()
                .onSubmit {
                    UserDefaults.standard.set(false, forKey: "onboardingComplete")
                }
            
        } else {
            
            
#if os(macOS)
            // xxxxxxxxxx   Section for macOS   xxxxxxxxxx
            
            macOSTabView(
                content: [
                    (
                        title: "Apple",
                        view: AnyView (
                            viewWeb0()
                        )
                    ),
                    (
                        title: "BMW",
                        view: AnyView(
                            viewWeb1()
                        )
                    ),
                    (
                        title: "Github",
                        view: AnyView (
                            viewWeb2()
                        )
                    )
                ]
            )
            
            
#else
            
            @Bindable var settingsData = settingsDataArray[0]

            // xxxxxxxxxx   Section for iOS   xxxxxxxxxx
            NavigationStack {
                
                GeometryReader { geometry in
                    
                    ZStack {
                        
                        
                        // ***** Navigation Bar *****
                        VStack(spacing: 0) {
                            
                            if(!settingsData.navOnTop) {
                                Spacer()
                            }
                            
                            HStack(alignment: .center, spacing: 0) {
                                
                                Button(action: {
                                    showOptions.toggle()
                                }, label: {
                                    
                                    Image(systemName: "slider.vertical.3")
                                        .resizable()
                                        .foregroundColor(.blue)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: !settingsData.bigIcons ? 18 : 24, height: !settingsData.bigIcons ? 18 : 24, alignment: .center)
                                    
                                })
                                .frame(width: 50, height: 40, alignment: .center)
                                .sheet(isPresented: $showOptions){
                                    iOSOptionsView(viewModel: viewModel)
                                        .presentationDetents([.large])
                                        .environmentObject(globals)
                                    
                                }
                                
                                
                                if webSites.count == 1 {
                                    
                                    Spacer()
                                    
                                    NavButton(actionType: "main", imageData: webSites[0].siteFavIcon!, textStr: webSites[0].siteName)
                                    
                                    Spacer()
                                    
                                } else if webSites.count == 2 {
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        globals.currentTab = 0
                                        
                                    }, label: {
                                        NavButton(actionType: "main", imageData: webSites[0].siteFavIcon!, textStr: webSites[0].siteName)
                                    })
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        globals.currentTab = 1
                                        
                                    }, label: {
                                        NavButton(actionType: "main", imageData: webSites[1].siteFavIcon!, textStr: webSites[1].siteName)
                                    })
                                    
                                    Spacer()
                                    
                                    
                                    
                                } else if webSites.count > 2 {
                                    
                                    Button(action: {
                                        
                                        if globals.currentTab == 0 {
                                            globals.nextTab = globals.currentTab
                                            globals.currentTab = webSites.count - 1
                                            globals.previousTab = globals.currentTab - 1
                                            
                                        } else if globals.currentTab == 1 {
                                            globals.nextTab = globals.currentTab
                                            globals.currentTab -= 1
                                            globals.previousTab = webSites.count - 1
                                            
                                        } else if globals.currentTab > 1 {
                                            globals.nextTab = globals.currentTab
                                            globals.currentTab -= 1
                                            globals.previousTab = globals.currentTab - 1
                                            
                                        } else if globals.currentTab == webSites.count - 1 {
                                            globals.nextTab = globals.currentTab
                                            globals.currentTab -= 1
                                            globals.previousTab = globals.currentTab - 1
                                        }
                                        
                                    }, label: {
                                        NavButton(actionType: "previous", imageData: webSites[globals.previousTab].siteFavIcon!, textStr: webSites[globals.previousTab].siteName)
                                    })
                                    .frame(width: 40, height: 40, alignment: .center)
                                    .padding(.leading, 5)
                                    .onAppear {
                                        globals.previousTab = webSites.count - 1
                                    }
                                    
                                    Spacer()
                                    
                                    NavButton(actionType: "main", imageData: webSites[globals.currentTab].siteFavIcon!, textStr: webSites[globals.currentTab].siteName)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        
                                        if globals.currentTab == 0 {
                                            globals.previousTab = globals.currentTab
                                            globals.currentTab += 1
                                            globals.nextTab = globals.currentTab + 1
                                            
                                        } else if globals.currentTab < webSites.count - 2 {
                                            globals.previousTab = globals.currentTab
                                            globals.currentTab += 1
                                            globals.nextTab = globals.currentTab + 1
                                            
                                        } else if globals.currentTab == webSites.count - 2 {
                                            globals.previousTab = globals.currentTab
                                            globals.currentTab += 1
                                            globals.nextTab = 0
                                            
                                        } else if globals.currentTab == webSites.count - 1 {
                                            globals.previousTab = globals.currentTab
                                            globals.currentTab = 0
                                            globals.nextTab = 1
                                            
                                        }
                                        
                                    }, label: {
                                        NavButton(actionType: "next", imageData: webSites[globals.nextTab].siteFavIcon!, textStr: webSites[globals.nextTab].siteName)
                                        
                                    })
                                    .frame(width: 40, height: 40, alignment: .center)
                                    .padding(.trailing, 5)
                                }
                                
                                Button(action: {
                                    self.mode.wrappedValue.dismiss()
                                }, label: {
                                    Image(systemName: "equal.square")
                                        .resizable()
                                        .foregroundColor(.blue)
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: !settingsData.bigIcons ? 18 : 24, height: !settingsData.bigIcons ? 18 : 24, alignment: .center)
                                })
                                .frame(width: 50, height: 40, alignment: .center)
                                
                            }
                            .background(.thinMaterial).opacity(settingsData.opacity)
                            .padding(.bottom, settingsData.navOnTop ? 0 : 20)
                            
                            if(settingsData.navOnTop) {
                                Spacer()
                            }
                        }
                        .zIndex(1)
                        .onAppear {
                            // Initialize Ad-Blocker
                            if let settings = settingsDataArray.first {
                                Task {
                                    await viewModel.initializeBlocker(isEnabled: settings.enableAdBlock)
                                }
                            }
                            
                            // Play Welcome Sound
                            playSound()
                            
                            //Print path to simulator file path, if necessary
                            //print(FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!)
                        }
                        
                        ZStack {

                            ForEach(0..<webSites.count, id: \.self) { index in
                                WebViewContainer(webViewController: viewModel.getWebViewController(index))
                                    .zIndex(globals.currentTab == index ? 1 : 0)
                                    .onAppear {
                                        if let url = URL(string: webSites[index].siteURL) {
                                            viewModel.getWebViewController(index).load(url: url)
                                        }
                                    }
                            }

                            // This VStack shows the loading progress of the content blocker
                            VStack {
                                Spacer()
                                
                                if settingsData.enableAdBlock && viewModel.loadedRuleLists < viewModel.totalRuleLists {
                                    HStack {
                                        ProgressView()
                                            .padding(.horizontal)
                                        Text("Loading ad-blockers: \(viewModel.loadedRuleLists)/\(viewModel.totalRuleLists)")
                                            .font(.caption)
                                    }
                                    .padding()
                                    .background(.thinMaterial).opacity(settingsData.opacity)
                                    .cornerRadius(10)
                                    // ***** Invisible box to push up the message *****
                                    Rectangle()
                                    .opacity(0)
                                    .frame(width: 300, height: 70, alignment: .center)

                                }
                            }
                            .zIndex(2)

                        }
                        .zIndex(0)
                        
                    }
                    .background(Color("BackgroundColorTopBar"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                }
                .ignoresSafeArea(edges: .bottom)
            }
            
#endif
        }
        
    }
    
    
    
    
    
    func playSound() {
        if let path = Bundle.main.path(forResource: "StartSound", ofType: "wav") {
            let url = URL(fileURLWithPath: path)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            } catch {
                print("Error playing sound: \(error)")
            }
        }
    }



    
}


//MARK: macOS Content View
/*
 struct ContentView: View {
     @Environment(\.modelContext) private var modelContext
     @Query private var items: [Item]

     var body: some View {
         NavigationSplitView {
             List {
                 ForEach(items) { item in
                     NavigationLink {
                         Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                     } label: {
                         Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                     }
                 }
                 .onDelete(perform: deleteItems)
             }
             .navigationSplitViewColumnWidth(min: 180, ideal: 200)
             .toolbar {
                 ToolbarItem {
                     Button(action: addItem) {
                         Label("Add Item", systemImage: "plus")
                     }
                 }
             }
         } detail: {
             Text("Select an item")
         }
     }

     private func addItem() {
         withAnimation {
             let newItem = Item(timestamp: Date())
             modelContext.insert(newItem)
         }
     }

     private func deleteItems(offsets: IndexSet) {
         withAnimation {
             for index in offsets {
                 modelContext.delete(items[index])
             }
         }
     }
 }

 #Preview {
     ContentView()
         .modelContainer(for: Item.self, inMemory: true)
 }

 */


// MARK: Content View Model
class ContentViewModel: ObservableObject {

    private let blockListManager = BlockListManager()
    @Published private(set) var webViewControllers: [ContentBlockingWebViewController] = []
    @Published var loadedRuleLists: Int = 0
    @Published var totalRuleLists: Int = 0
    private var currentCompiledRules: [WKContentRuleList] = []
    
    private let blockListURLs: [URL] = [
        "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_2_Base/filter.txt",
        "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_3_Spyware/filter.txt",
        "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_4_Social/filter.txt",
        "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_11_Mobile/filter.txt",
        "https://raw.githubusercontent.com/AdguardTeam/FiltersRegistry/master/filters/filter_14_Annoyances/filter.txt",
        "https://filters.adtidy.org/extension/chromium-mv3/filters/24.txt"
    ].compactMap { URL(string: $0) }
    
    init() {
        // Initialize all web view controllers
        webViewControllers = (0...4).map { _ in
            let controller = ContentBlockingWebViewController()
            controller.loadView()
            controller.setupWebView()
            controller.setupRefreshControl()
            controller.loadAndInjectScript()
            return controller
        }
    }
    
    func getWebViewController(_ index: Int) -> ContentBlockingWebViewController {
        guard index < webViewControllers.count else {
            print("ERROR: Requested web view controller index \(index) out of bounds")
            return ContentBlockingWebViewController()
        }
        return webViewControllers[index]
    }

    @MainActor
    func initializeBlocker(isEnabled: Bool) async {

        if isEnabled {
            
            totalRuleLists = blockListURLs.count
            loadedRuleLists = 0
            
            for (_, url) in blockListURLs.enumerated() {
                do {
                    loadedRuleLists += 1
                    let result = try await blockListManager.processURL(url)
                    if let compiledRules = result.compiled {
                        currentCompiledRules.append(compiledRules)
                        // Apply rules to all web views
                        for webViewController in webViewControllers {
                            try await webViewController.addContentRules(with: [compiledRules])
                        }
                    }
                } catch {
                    print("Error processing block list: \(url): \(error.localizedDescription)")
                    loadedRuleLists += 1
                }
            }
        }
    }
    
    @MainActor
    func toggleBlocking(isEnabled: Bool) async {
        
        if isEnabled {
            // Initialize the blocker if it's being enabled
            totalRuleLists = blockListURLs.count
            loadedRuleLists = 0
            
            for (_, url) in blockListURLs.enumerated() {
                do {
                    let result = try await blockListManager.processURL(url)
                    if let compiledRules = result.compiled {
                        currentCompiledRules.append(compiledRules)
                        // Apply rules to all web views
                        for webViewController in webViewControllers {
                            try await webViewController.addContentRules(with: [compiledRules])
                        }
                    }
                    loadedRuleLists += 1
                } catch {
                    print("Error processing block list \(url): \(error.localizedDescription)")
                    loadedRuleLists += 1
                }
            }
            print("Finished loading ad blocking rules")
        } else {
            // Clear all rules if it's being disabled
            currentCompiledRules = []
            loadedRuleLists = 0
            totalRuleLists = 0
            
            do {
                // Remove rules from all web views
                for webViewController in webViewControllers {
//                    try await webViewController.setupContentRules(with: [])
                    try await webViewController.removeContentRules()
                }
                print("Successfully removed all content rules")
            } catch {
                print("Error removing content rules: \(error.localizedDescription)")
            }
        }
    }
}










// MARK: Preview
#Preview {

    let globals = GlobalVariables()

    globals.currentTab = 1
    globals.previousTab = 0
    globals.nextTab = 2

    return ContentView()
        .environmentObject(globals)
        .modelContainer(for: [sitesStorage.self, settingsStorage.self])
}

