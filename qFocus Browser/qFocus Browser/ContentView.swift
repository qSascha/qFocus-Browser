//
//  ContentView.swift
//  qFocus Browser
//
//  Created by Sascha on 2025-01-25.
//

import SwiftUI
import SwiftData





// MARK: Content View
struct ContentView: View {
    @Query(
        filter: #Predicate<sitesStorage> { $0.siteName != ""},
        sort: \sitesStorage.siteOrder
    ) var webSites: [sitesStorage]
    @Query() var settingsDataArray: [settingsStorage]

    @Environment(\.presentationMode) var mode: Binding<PresentationMode>
    @Environment(\.modelContext) private var modelContext

    @StateObject var globals = GlobalVariables()

    @State private var showingDebugView = false

    @AppStorage("onboardingComplete") var onboardingComplete: Bool = false

//    private var webViewControllers: [ContentBlockingWebViewController] = []
    


    
    
    
    var body: some View {

//        if true {
        if ( !onboardingComplete) {
            
            Onboarding()
                .onSubmit {
                    UserDefaults.standard.set(false, forKey: "onboardingComplete")
                }
            
        } else {
            @Bindable var settingsData = settingsDataArray[0]


            GeometryReader { geometry in
                
                ZStack {
                    
                    // ***** Navigation Bar *****
                    NavBar()
                    .zIndex(5)
                    
                    // ***** Loading screen for ad-blocker *****
                    AdBlockLoadStatus()
                    .zIndex(1)

                    // ***** Web Views *****
                    WebViews()
                    .zIndex(0)

                }
                .background(Color("BackgroundColorTopBar"))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
            }
            .ignoresSafeArea(edges: .bottom)
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



