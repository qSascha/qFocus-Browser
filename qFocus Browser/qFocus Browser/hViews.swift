//
//  hView.swift
//  qFocus Browser
//
//  Created by Sascha on 2025-01-25.
//
import SwiftUI
import SwiftData







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
            Image(uiImage: UIImage(data: imageData) ?? UIImage(systemName: "exclamationmark.circle")!)
                .resizable()
                .foregroundColor(.blue)
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24, alignment: .center)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 24
                    )
                )

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
                .frame(width: 12, height: 20, alignment: .center)
            
            Image(uiImage: UIImage(data: imageData) ?? UIImage(systemName: "exclamationmark.circle")!)
                .resizable()
                .foregroundColor(.blue)
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24, alignment: .center)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 24
                    )
                )
            
        case "next":
            Image(uiImage: UIImage(data: imageData) ?? UIImage(systemName: "exclamationmark.circle")!)
                .resizable()
                .foregroundColor(.blue)
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24, alignment: .center)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 24
                    )
                )

            Image(systemName: "chevron.forward")
                .resizable()
                .foregroundColor(.blue)
                .aspectRatio(contentMode: .fit)
                .frame(width: 12, height: 20, alignment: .center)
            
        default:
            Text("")
        }
        
        
    }
}



//MARK: View: Navigation Bar
struct NavBar: View {
    @Query(
        filter: #Predicate<sitesStorage> { $0.siteName != ""},
        sort: \sitesStorage.siteOrder
    ) var webSites: [sitesStorage]
    @Query() var settingsDataArray: [settingsStorage]

    @State private var showOptions = false

    @EnvironmentObject private var viewModel: ContentViewModel
    @StateObject var globals = GlobalVariables()

    
    
    var body: some View {
        @Bindable var settingsData = settingsDataArray[0]

        VStack(spacing: 0) {
            
            if settingsData.navOption != .top {
                Spacer()
            }
            
            HStack(alignment: .center, spacing: 0) {
                // ***** Invisible box to push button to the right *****
                Rectangle()
                .opacity(0)
                .frame(width: 10, height: 10)

                Button(action: {
                    showOptions.toggle()
                }, label: {
                    
                    Image(systemName: "slider.vertical.3")
                        .resizable()
                        .foregroundColor(.blue)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24, alignment: .center)
                    
                })
                .frame(width: 50, height: 40, alignment: .center)
/*                .sheet(isPresented: $showOptions){
                    iOSOptionsView(viewModel: viewModel)
                        .presentationDetents([.large])
                        .environmentObject(globals)

                }
*/
                
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
 
            }
            .background(.thinMaterial).opacity(settingsData.opacity)
            .padding(.bottom, settingsData.navOption != .bottom ? 0 : 20)
            
            if(settingsData.navOption == .top) {
                Spacer()
            }
        }
        
    }
    
}
    


//MARK: View: WebViews
struct WebViews: View {
    @Query(
        filter: #Predicate<sitesStorage> { $0.siteName != ""},
        sort: \sitesStorage.siteOrder
    ) var webSites: [sitesStorage]

    @EnvironmentObject private var viewModel: ContentViewModel
    @StateObject var globals = GlobalVariables()

    
    
    var body: some View {

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
        }
    }
}





//MARK: View: AdBlockLoadStatus
struct AdBlockLoadStatus: View {
    @Query(
        filter: #Predicate<sitesStorage> { $0.siteName != ""},
        sort: \sitesStorage.siteOrder
    ) var webSites: [sitesStorage]
    @Query() var settingsDataArray: [settingsStorage]

    @EnvironmentObject private var viewModel: ContentViewModel

    
    
    var body: some View {
        @Bindable var settingsData = settingsDataArray[0]

        VStack {
            Spacer()
            
            if settingsData.enableAdBlock && viewModel.loadedRuleLists < viewModel.totalRuleLists {
                HStack {
                    ProgressView()
                        .padding(.horizontal)
                    Text("Updating ad-blockers: \(viewModel.loadedRuleLists+1)/\(viewModel.totalRuleLists)")
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
        .onAppear {
            // Enable Ad-Blocker, if onboarding finalized.
            if let settings = settingsDataArray.first {
                Task {
                    await try viewModel.initializeBlocker(isEnabled: settings.enableAdBlock)
                }
            }
          
            //Print path to simulator file path, if necessary
            //print(FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!)
        }

    }
}
