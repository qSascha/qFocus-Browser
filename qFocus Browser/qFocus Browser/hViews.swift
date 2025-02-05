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

    @State private var isShowingButtons = false
    @State private var showShareSheet = false
    @GestureState private var isDragging = false
    @GestureState private var isLongPressing = false
    
    let pressFeedback = UIImpactFeedbackGenerator(style: .rigid)
    let tapFeedback = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        @Bindable var settingsData = settingsDataArray[0]
        
        ZStack {
            // Replace Button with Image and add tap gesture
            ZStack {
                Circle()
                    .strokeBorder(Color.blue, lineWidth: 2)
                    .frame(width: 52, height: 52)

                Image(systemName: "command.circle.fill")
                    .resizable()
                    .frame(width: 44, height: 44)
                    .foregroundColor(.blue)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: isDragging || isLongPressing ? 6 : 3)
            }
            .scaleEffect(isDragging || isLongPressing ? 1.1 : 1.0)
            .position(x: CGFloat(settingsData.freeFlowX), y: CGFloat(settingsData.freeFlowY))
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
                                    settingsData.freeFlowX = Double(gesture.location.x)
                                    settingsData.freeFlowY = Double(gesture.location.y)
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
                HStack(spacing: 2) {
                    VStack(spacing: 0) {
                        // Top row of icons (even indexed icons)
                        HStack(spacing: 4) {
                            ForEach(webSites.indices, id: \.self) { index in
                                if index % 2 == 0 {  // Even indices go in top row
                                    Button(action: {
                                        globals.currentTab = index
                                        isShowingButtons = false
                                    }, label: {
                                        Image(uiImage: UIImage(data: webSites[index].siteFavIcon!) ?? UIImage(systemName: "exclamationmark.circle")!)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 32, height: 32)
                                            .clipShape(Circle())
                                            .padding(EdgeInsets(
                                                top: 8,
                                                leading: 10,
                                                bottom: 2,
                                                trailing: 10
                                            ))
                                    })
                                }
                            }
                        }
                        
                        // Bottom row of icons (odd indexed icons)
                        HStack(spacing: 2) {
                            ForEach(webSites.indices, id: \.self) { index in
                                if index % 2 != 0 {  // Odd indices go in bottom row
                                    Button(action: {
                                        globals.currentTab = index
                                        isShowingButtons = false
                                    }, label: {
                                        Image(uiImage: UIImage(data: webSites[index].siteFavIcon!) ?? UIImage(systemName: "exclamationmark.circle")!)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 32, height: 32)
                                            .clipShape(Circle())
                                            .padding(EdgeInsets(
                                                top: 2,
                                                leading: 10,
                                                bottom: 8,
                                                trailing: 10
                                            ))
                                    })
                                }
                            }
                        }
                    }
                    .background(.thinMaterial).opacity(settingsData.opacity)

                    // Settings and Share buttons
                    VStack(spacing: 2) {
                        
                        Spacer()
                        
                        Button(action: {
                            showShareSheet = true
                        }) {
                            Image(systemName: "square.and.arrow.up")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .foregroundColor(.blue)
                                .padding(EdgeInsets(
                                    top: 4,
                                    leading: 4,
                                    bottom: 2,
                                    trailing: 6
                                ))
                        }
                        .frame(height: 34)
                        
                        Button(action: {
                            globals.showOptionsView = true
                        }) {
                            Image(systemName: "slider.vertical.3")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundColor(.blue)
                                .padding(EdgeInsets(
                                    top: 2,
                                    leading: 4,
                                    bottom: 4,
                                    trailing: 6
                                ))
                        }
                        .frame(height: 34)
                        
                        Spacer()
                        
                    }
                    .frame(height: 76)
//                    .padding( 4)
                }
                .background(Color(UIColor.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 10)
                .position(
                    x: min(max(CGFloat(settingsData.freeFlowX), 100), UIScreen.main.bounds.width - 100),
                    y: min(max(CGFloat(settingsData.freeFlowY) - 100, 100), UIScreen.main.bounds.height - 100)
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .zIndex(8)
        .sheet(isPresented: $showShareSheet) {
            if let url = URL(string: webSites[globals.currentTab].siteURL) {
                ShareSheet(activityItems: [url])
            }
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

    

    var body: some View {
        @Bindable var settingsData = settingsDataArray[0]

        VStack(spacing: 0) {
            
            if settingsData.navOption != .top {
                Spacer()
            }
            
            HStack(alignment: .center, spacing: 0) {
                
                if settingsData.navOption != .freeFlow {
                    
                    // ***** Invisible box to push button to the right *****
                    Rectangle()
                        .opacity(0)
                        .frame(width: 10, height: 10)
                    
                    Button(action: {
                        globals.showOptionsView.toggle()
                    }, label: {
                        
                        Image(systemName: "slider.vertical.3")
                            .resizable()
                            .foregroundColor(.blue)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24, alignment: .center)
                        
                    })
                    .frame(width: 50, height: 40, alignment: .center)

                    Spacer()
                }
                
                ForEach(webSites.indices, id: \.self) { index in
                    Button(action: {
                        globals.currentTab = index
                    }, label: {
                        Image(uiImage: UIImage(data: webSites[index].siteFavIcon!) ?? UIImage(systemName: "exclamationmark.circle")!)
                            .resizable()
                            .foregroundColor(.blue)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 32, height: 32, alignment: .center)
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 16
                                )
                            )
                    })
                    .frame(width: 40, height: 40, alignment: .center)
                    
                    if settingsData.navOption != .freeFlow { Spacer() }
                    
                }
 
                Spacer()

            }
            .background(.thinMaterial).opacity(settingsData.opacity)
            .padding(.bottom, (settingsData.navOption == .bottom && settingsData.showBottomBar) ? 0 : 15)
            
            if(settingsData.navOption == .top) {
                Spacer()
            }
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
            if(settingsData.navOption == .top) {
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
                                await viewModel.updateWebView(at: index, with: webSites[index].siteURL, jsScript1: webSites[index].jsScript1, jsScript2: webSites[index].jsScript2, jsScript3: webSites[index].jsScript3)
                            }
                        }
                        .onChange(of: webSites[index].siteURL) { _, newValue in
                            Task {
                                await viewModel.updateWebView(at: index, with: newValue, jsScript1: webSites[index].jsScript1, jsScript2: webSites[index].jsScript2, jsScript3: webSites[index].jsScript3)
                            }
                        }
                }
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
                .background(.thinMaterial).opacity(settingsData.opacity)
                .cornerRadius(10)

                // ***** Invisible box to push up the message *****
                Rectangle()
                .opacity(0)
                .frame(width: 300, height: 70, alignment: .center)

            }
        }

    }
}
