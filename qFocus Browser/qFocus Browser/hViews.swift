//
//  hViews.swift
//  qFocus Browser
//
//  Created by Sascha on 2025-01-25.
//
import SwiftUI
import SwiftData






//MARK: Floating Nav Bar
struct FloatingNavBar: View {
    @Query(
        filter: #Predicate<sitesStorage> { $0.siteName != ""},
        sort: \sitesStorage.siteOrder
    ) var webSites: [sitesStorage]
    @Query() var settingsDataArray: [settingsStorage]

    @EnvironmentObject private var viewModel: ContentViewModel
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var globals: GlobalVariables

    @ObservedObject var scriptManager: ScriptManager

    @State private var isShowingButtons = false
    @State private var showShareSheet = false
    @GestureState private var isDragging = false
    @GestureState private var isLongPressing = false
    
    let pressFeedback = UIImpactFeedbackGenerator(style: .rigid)
    let tapFeedback = UIImpactFeedbackGenerator(style: .medium)

    
    
    
    var body: some View {
        @Bindable var settingsData = settingsDataArray[0]
        
        GeometryReader { geometry in
            
            
            ZStack {
                // Image and add tap gesture
                ZStack {
                    Circle()
                        .strokeBorder(Color.qBlueLight, lineWidth: 2)
                        .frame(width: 52, height: 52)
                    
                    Image(systemName: "command.circle.fill")
                        .resizable()
                        .frame(width: 44, height: 44)
                        .foregroundColor(.qBlueLight)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(radius: isDragging || isLongPressing ? 6 : 3)
                }
                .scaleEffect(isDragging || isLongPressing ? 1.1 : 1.0)
                //            .position(x: CGFloat(settingsData.freeFlowX), y: CGFloat(settingsData.freeFlowY))
                .position(
                    x: CGFloat(settingsData.freeFlowXPercent) * geometry.size.width,
                    y: CGFloat(settingsData.freeFlowYPercent) * geometry.size.height
                )
                .onTapGesture {
                    withAnimation(.spring()) {
                        isShowingButtons.toggle()
                    }
                    tapFeedback.impactOccurred(intensity: 0.5)
                }
                .gesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .sequenced(before: DragGesture())
                        .updating($isLongPressing) { value, state, _ in
                            switch value {
                            case .first(true):
                                state = true
                            case .second(true, nil):
                                pressFeedback.impactOccurred(intensity: 1.0)
                                state = true
                            case .second(true, _):
                                state = true
                            default:
                                state = false
                            }
                        }
                        .simultaneously(with:
                                            DragGesture()
                            .updating($isDragging) { value, state, _ in
                                state = true
                            }
                            .onChanged { gesture in
                                if isDragging {
                                    let newXPercent = Double(gesture.location.x / geometry.size.width)
                                    let newYPercent = Double(gesture.location.y / geometry.size.height)
                                    
                                    // Clamp values between 0 and 1
                                    settingsData.freeFlowXPercent = max(0, min(1, newXPercent))
                                    settingsData.freeFlowYPercent = max(0, min(1, newYPercent))
                                    
                                }
                            }
                            .onEnded { _ in
                                pressFeedback.impactOccurred(intensity: 0.5)
                                //Save new X and Y position of the button
                                try? modelContext.save()
                            }
                                       )
                )
                .animation(.interactiveSpring(), value: isDragging)
                
                // Popup window with navigation buttons
                if isShowingButtons {
                    HStack() {   // Two areas, right for share and options, left for all web sites
                        
                        VStack() {
                            // Top row of icons (even indexed icons)
                            HStack() {
                                ForEach(webSites.indices, id: \.self) { index in
                                    if index % 2 == 0 {  // Even indices go in top row
                                        MenuButton(
                                            index: index,
                                            webSites: webSites,
                                            scriptManager: scriptManager
                                        ) {
                                            globals.currentTab = index
                                            isShowingButtons = false
                                        }
                                    }
                                }
                            }
                            .padding(EdgeInsets(
                                top: 10,
                                leading: 10,
                                bottom: 3,
                                trailing: 5
                            ))
                            
                            // Bottom row of icons (odd indexed icons)
                            HStack() {
                                ForEach(webSites.indices, id: \.self) { index in
                                    if index % 2 != 0 {  // Odd indices go in bottom row
                                        MenuButton(
                                            index: index,
                                            webSites: webSites,
                                            scriptManager: scriptManager
                                        ) {
                                            globals.currentTab = index
                                            isShowingButtons = false
                                        }
                                    }
                                }
                            }
                            .padding(EdgeInsets(
                                top: 3,
                                leading: 10,
                                bottom: 10,
                                trailing: 5
                            ))
                            
                        }
                        
                        // Settings and Share buttons
                        VStack() {
                            
                            Button(action: {
                                showShareSheet = true
                                isShowingButtons = false
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: (globals.menuIconSize * 0.75), height: (globals.menuIconSize * 0.75), alignment: .center)
                                    .foregroundColor(.white)
                                    .padding(EdgeInsets(
                                        top: 14,
                                        leading: 10,
                                        bottom: 7,
                                        trailing: 10
                                    ))
                                
                            }
                            
                            Button(action: {
                                globals.showOptionsView = true
                                isShowingButtons = false
                            }) {
                                Image(systemName: "slider.horizontal.3")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: (globals.menuIconSize * 0.75), height: (globals.menuIconSize * 0.75), alignment: .center)
                                    .foregroundColor(.white)
                                    .padding(EdgeInsets(
                                        top: 7,
                                        leading: 10,
                                        bottom: 14,
                                        trailing: 10
                                    ))
                                
                            }
                            
                        }
                        .background(Color(.qBlueDark))
                        
                    }
                    .background(Color(.qBlueLight))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 10)
                    .position(
                        x: CGFloat(settingsData.freeFlowXPercent) * geometry.size.width,
                        y: CGFloat(settingsData.freeFlowYPercent) * geometry.size.height
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .frame( width: geometry.size.width, height: geometry.size.height)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .zIndex(8)

    }
}


// MARK: Menu Button
private struct MenuButton: View {
    let index: Int
    let webSites: [sitesStorage]
    @ObservedObject var scriptManager: ScriptManager
    let action: () -> Void

    @EnvironmentObject var globals: GlobalVariables


    var body: some View {
        let host = URL(string: webSites[index].siteURL)?.host ?? ""
        _ = scriptManager.domainsWithInjectedScripts.contains(host)
        
        return Button(action: action) {
            Image(uiImage: UIImage(data: webSites[index].siteFavIcon!) ?? UIImage(systemName: "exclamationmark.circle")!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: globals.menuIconSize, height: globals.menuIconSize)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .fill(scriptManager.domainsWithInjectedScripts.contains(URL(string: webSites[index].siteURL)?.host ?? "") ? Color.green : Color.clear)
                        .frame(width: 8, height: 8)
                    , alignment: .bottomLeading
                )
        }
    }
}




// ShareSheet struct for UIActivityViewController
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}








//MARK: View: Navigation Bar
struct NavBar: View {
    @Query(
        filter: #Predicate<sitesStorage> { $0.siteName != ""},
        sort: \sitesStorage.siteOrder
    ) var webSites: [sitesStorage]
    @Query() var settingsDataArray: [settingsStorage]

    @EnvironmentObject private var viewModel: ContentViewModel
    @EnvironmentObject var globals: GlobalVariables

    @ObservedObject var scriptManager: ScriptManager


    var body: some View {
        @Bindable var settingsData = settingsDataArray[0]

        VStack(spacing: 0) {
            
            HStack(alignment: .center) {
                
                // ***** Invisible box to push button to the right *****
                Rectangle()
                    .opacity(0)
                    .frame(width: 10, height: 10)
                
                Button(action: {
                    globals.showOptionsView.toggle()
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                        .frame(width: (globals.menuIconSize * 0.75), height: (globals.menuIconSize * 0.75), alignment: .center)
                }

                Spacer()
                
                ForEach(webSites.indices, id: \.self) { index in

                    MenuButton(
                        index: index,
                        webSites: webSites,
                        scriptManager: scriptManager
                    ) {
                        globals.currentTab = index
                    }

                    Spacer()

                }
                
                Button(action: {
                    globals.showShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                        .frame(width: (globals.menuIconSize * 0.75), height: (globals.menuIconSize * 0.75), alignment: .center)
                }

                // ***** Invisible box to push button to the left *****
                Rectangle()
                    .opacity(0)
                    .frame(width: 10, height: 10)

            }
            
            Spacer()

        }
        .zIndex(5)

    }
    
}
    




//MARK: View: WebViews
struct WebViews: View {
    @Query(
        filter: #Predicate<sitesStorage> { $0.siteName != ""},
        sort: \sitesStorage.siteOrder
    ) var webSites: [sitesStorage]
    @Query() var settingsDataArray: [settingsStorage]

    @EnvironmentObject private var viewModel: ContentViewModel
    @EnvironmentObject var globals: GlobalVariables

    
    
    var body: some View {
        @Bindable var settingsData = settingsDataArray[0]

        VStack {
            if (settingsData.showNavBar) {
                Rectangle()
                    .opacity(0)
                    .frame(width: 30, height: 30, alignment: .center)
            }
            
            ZStack {
                ForEach(0..<webSites.count, id: \.self) { index in
                    WebViewContainer(webViewController: viewModel.getWebViewController(index))
                        .zIndex(globals.currentTab == index ? 1 : 0)
                        .onAppear {
                            Task {
                                await viewModel.updateWebView(index: index, site: webSites[index])
                            }
                        }
                        .onChange(of: webSites[index].siteURL) { _, _ in
                            viewModel.resetInitialLoadState(for: index)
                            Task {
                                await viewModel.updateWebView(index: index, site: webSites[index])
                            }
                        }
                        .onChange(of: webSites[index].enableJSBlocker) { _, _ in
                            Task {
                                await viewModel.updateWebView(index: index, site: webSites[index])
                            }
                        }
                        .onChange(of: webSites[index].requestDesktop) { _, _ in
                            Task {
                                await viewModel.updateWebView(index: index, site: webSites[index])
                            }
                        }
                }


/*
                ForEach(0..<webSites.count, id: \.self) { index in
                    WebViewContainer(webViewController: viewModel.getWebViewController(index))
                        .zIndex(globals.currentTab == index ? 1 : 0)
                        .onAppear {
                            Task {
                                await viewModel.updateWebView(index: index, urlString: webSites[index].siteURL, enableJSBlocker: webSites[index].enableJSBlocker, requestDesktop: webSites[index].requestDesktop)
                            }
                        }
                        .onChange(of: webSites[index].siteURL) { oldValue, newValue in
                            viewModel.resetInitialLoadState(for: index)
                            Task {
                                await viewModel.updateWebView(index: index, urlString: newValue, enableJSBlocker: webSites[index].enableJSBlocker, requestDesktop: webSites[index].requestDesktop)
                            }
                        }
                        .onChange(of: webSites[index].enableJSBlocker) { oldValue, newValue in
                            Task {
                                await viewModel.updateWebView( index: index, urlString: webSites[index].siteURL, enableJSBlocker: newValue, requestDesktop: webSites[index].requestDesktop)
                            }
                        }
                        .onChange(of: webSites[index].requestDesktop) { oldValue, newValue in
                            Task {
                                await viewModel.updateWebView( index: index, urlString: webSites[index].siteURL, enableJSBlocker: webSites[index].enableJSBlocker, requestDesktop: newValue)
                            }
                        }
                }
*/


            }
        }
    }
}

struct WebViewContainer: UIViewControllerRepresentable {
    let webViewController: ContentBlockingWebViewController
    
    func makeUIViewController(context: Context) -> ContentBlockingWebViewController {
        return webViewController
    }
    
    func updateUIViewController(_ uiViewController: ContentBlockingWebViewController, context: Context) {
        // Update the view controller if needed
    }
}




//MARK: View: AdBlockLoadStatus
struct AdBlockLoadStatus: View {

    @Query() var settingsDataArray: [settingsStorage]

    @EnvironmentObject var viewModel: ContentViewModel

    
    
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
                .background(Color.qBlueLight.opacity(0.7))
                .cornerRadius(10)

                // ***** Invisible box to push up the message *****
                Rectangle()
                .opacity(0)
                .frame(width: 300, height: 70, alignment: .center)

            }
        }

    }
}
