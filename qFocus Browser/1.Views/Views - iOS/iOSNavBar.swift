//
//  iOSNavBar.swift
//  qFocus Browser
//
//
import SwiftUI
import FactoryKit



struct NavBar: View {
    @InjectedObject(\.navigationVM) var viewModel: NavigationVM

    @ObservedObject var coordinator: AppCoordinator
    @Namespace var navBarAnimation

    
    
    var body: some View {
        if #available(iOS 26.0, *) {
            
            VStack {
                Spacer()
                
                ZStack {
                    if viewModel.minimizeNavBar {
                        
                        Button {
                            viewModel.minimizeNavBar = false
                        } label: {
                            Group {
                                if viewModel.selectedWebIndex >= 0 && viewModel.selectedWebIndex < viewModel.sitesButton.count {
                                    
                                    let faviconData = viewModel.sitesButton[viewModel.selectedWebIndex].siteFavIcon
                                    let faviconImage = faviconData.flatMap { UIImage(data: $0) }
                                    
                                    HStack() {
                                        if let image = faviconImage {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 16, height: 16)
                                                .clipShape(Circle())
                                        } else {
                                            Image(systemName: "globe")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 16, height: 16)
                                                .clipShape(Circle())
                                        }
                                        Text(viewModel.sitesButton[viewModel.selectedWebIndex].siteName)
                                            .font(.caption)
                                    }
                                    .padding(.vertical, 2)
                                    .padding(.horizontal, 6)

                                } else {
                                    Text("Loading...")
                                        .font(.caption)
                                        .padding()
                                }
                            }

                        }
                        .glassEffect()
                        .padding(.bottom, 20)
                        .matchedGeometryEffect(id: "navBar", in: navBarAnimation)
                        
                    } else {
                        
                        HStack(alignment: .center) {
                            
                            Button(action: {
                                coordinator.showOptionsView.toggle()
                            }) {
                                Image(systemName: "slider.horizontal.3")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 28, height: 28, alignment: .center)
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 14)
                            .glassEffect(.regular.interactive(true))
                            .padding(.leading, 20)
                            
                            Spacer()
                            
                            WebsiteSelectorView(
                                selectedIndex: $viewModel.selectedWebIndex,
                                websites: viewModel.sitesButton
                            )
                            
                            Spacer()
                            
                            Button(action: {
                                coordinator.showShareSheet.toggle()
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 28, height: 28, alignment: .center)
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 14)
                            .glassEffect(.regular.interactive(true))
                            .padding(.trailing, 20)
                            
                        }
                        .padding(.bottom, 20)
                        .matchedGeometryEffect(id: "navBar", in: navBarAnimation)
                        
                    }
                }
                .animation(.easeInOut(duration: 0.35), value: viewModel.minimizeNavBar)
            }
            .zIndex(5)

        } else {

            //Legacy Version
            VStack {
                Spacer()
                
                ZStack {
                    if viewModel.minimizeNavBar {
                        
                        Button {
                            viewModel.minimizeNavBar = false
                        } label: {
                            Group {
                                if viewModel.selectedWebIndex >= 0 && viewModel.selectedWebIndex < viewModel.sitesButton.count {
                                    
                                    let faviconData = viewModel.sitesButton[viewModel.selectedWebIndex].siteFavIcon
                                    let faviconImage = faviconData.flatMap { UIImage(data: $0) }
                                    
                                    HStack() {
                                        if let image = faviconImage {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 16, height: 16)
                                                .clipShape(Circle())
                                        } else {
                                            Image(systemName: "globe")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 16, height: 16)
                                                .clipShape(Circle())
                                        }
                                        Text(viewModel.sitesButton[viewModel.selectedWebIndex].siteName)
                                            .font(.caption)
                                    }
                                    .padding(.vertical, 2)
                                    .padding(.horizontal, 6)

                                } else {
                                    Text("Loading...")
                                        .font(.caption)
                                        .padding()
                                }
                            }

                        }
                        .background(Color.gray.gradient.opacity(0.94))
                        .cornerRadius(20)
                        .padding(.bottom, 20)
                        .matchedGeometryEffect(id: "navBar", in: navBarAnimation)
                        
                    } else {
                        
                        HStack(alignment: .center) {
                            
                            Button(action: {
                                coordinator.showOptionsView.toggle()
                            }) {
                                Image(systemName: "slider.horizontal.3")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 28, height: 28, alignment: .center)
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 14)
                            .background(Color.gray.gradient.opacity(0.94))
                            .cornerRadius(20)
                            .padding(.leading, 20)
                            
                            Spacer()
                            
                            WebsiteSelectorView(
                                selectedIndex: $viewModel.selectedWebIndex,
                                websites: viewModel.sitesButton
                            )
                            
                            Spacer()
                            
                            Button(action: {
                                coordinator.showShareSheet.toggle()
                            }) {
                                Image(systemName: "square.and.arrow.up")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 28, height: 28, alignment: .center)
                            }
                            .padding(.vertical, 14)
                            .padding(.horizontal, 14)
                            .background(Color.gray.gradient.opacity(0.94))
                            .cornerRadius(20)
                            .padding(.trailing, 20)
                            
                        }
                        .padding(.bottom, 20)
                        .matchedGeometryEffect(id: "navBar", in: navBarAnimation)
                        
                    }
                }
                .animation(.easeInOut(duration: 0.35), value: viewModel.minimizeNavBar)
            }
            .zIndex(5)
        }

    }
}




//MARK: WebSite Selector View
struct WebsiteSelectorView: View {
    @InjectedObject(\.navigationVM) var viewModel: NavigationVM
    @InjectedObject(\.mainVM) var mainVM: MainVM

    @Binding var selectedIndex: Int
    let websites: [SitesNavButton]
    


    var body: some View {
        if #available(iOS 26.0, *) {
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        
                        ForEach(Array(websites.enumerated()), id: \.element.id) { idx, site in
                            let faviconImage = site.siteFavIcon.flatMap { UIImage(data: $0) }
                            
                            if selectedIndex == idx {
                                
                                // Selected button with glass effect
                                Button(action: {
                                    selectedIndex = idx
                                    withAnimation(.easeInOut) {
                                        proxy.scrollTo(idx, anchor: .center)
                                    }
                                    mainVM.updateTopAreaColor()

                                }) {
                                    VStack(spacing: 0) {
                                        if let image = faviconImage {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 30, height: 30)
                                                .clipShape(Circle())
                                        } else {
                                            Image(systemName: "globe")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 30, height: 30)
                                                .clipShape(Circle())
                                        }
                                        
                                        Text (site.siteName)
                                            .font(.caption)
                                    }
                                    .frame(width: 100, height: 48)
                                    .padding(.vertical, 2)
                                }
                                .id(idx)
                                .glassEffect()
                                .padding(.vertical, 4)
                                .animation(.easeInOut, value: selectedIndex)
                                
                            } else {
                                
                                // Non-selected item
                                Button(action: {
                                    selectedIndex = idx
                                    withAnimation(.easeInOut) {
                                        proxy.scrollTo(idx, anchor: .center)
                                    }
                                    mainVM.updateTopAreaColor()
                                }) {
                                    VStack(spacing: 0) {
                                        if let image = faviconImage {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 30, height: 30)
                                                .clipShape(Circle())
                                        } else {
                                            Image(systemName: "globe")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 30, height: 30)
                                                .clipShape(Circle())
                                        }
                                        
                                        Text (site.siteName)
                                            .font(.caption)
                                    }
                                    .frame(width: 70, height: 48)
                                    .padding(.vertical, 2)
                                }
                                .id(idx)
                                .padding(.vertical, 4)
                                .animation(.easeInOut, value: selectedIndex)
                                
                                
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .clipShape(Capsule())
                .glassEffect()
                .onChange(of: selectedIndex) {
                    withAnimation(.easeInOut) {
                        proxy.scrollTo(selectedIndex, anchor: .center)
                        CombineRepo.shared.selectWebView.send(selectedIndex)
                    }
                }
                .onAppear {
                    print("Scrolling to marker")
                    withAnimation(.easeInOut) {
                        proxy.scrollTo(selectedIndex, anchor: .center)
                    }
                }
            }
            .frame(height: 42)
            .coordinateSpace(name: "scroll")
            
            
        } else {
            
            //Legacy Version
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        
                        ForEach(Array(websites.enumerated()), id: \.element.id) { idx, site in
                            let faviconImage = site.siteFavIcon.flatMap { UIImage(data: $0) }
                            
                            if selectedIndex == idx {
                                
                                // Selected button with glass effect
                                Button(action: {
                                    selectedIndex = idx
                                    withAnimation(.easeInOut) {
                                        proxy.scrollTo(idx, anchor: .center)
                                    }
                                    mainVM.updateTopAreaColor()
                                }) {
                                    VStack(spacing: 0) {
                                        if let image = faviconImage {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 30, height: 30)
                                                .clipShape(Circle())
                                        } else {
                                            Image(systemName: "globe")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 30, height: 30)
                                                .clipShape(Circle())
                                        }
                                        
                                        Text (site.siteName)
                                            .font(.caption)
                                    }
                                    .frame(width: 100, height: 48)
                                    .padding(.vertical, 2)
                                }
                                .id(idx)
                                .background(Color.gray.gradient.opacity(0.94))
                                .cornerRadius(20)
                                .padding(.vertical, 4)
                                .animation(.easeInOut, value: selectedIndex)

                            } else {
                                
                                // Non-selected item
                                Button(action: {
                                    selectedIndex = idx
                                    withAnimation(.easeInOut) {
                                        proxy.scrollTo(idx, anchor: .center)
                                    }
                                    mainVM.updateTopAreaColor()
                                }) {
                                    VStack(spacing: 0) {
                                        if let image = faviconImage {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 30, height: 30)
                                                .clipShape(Circle())
                                        } else {
                                            Image(systemName: "globe")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 30, height: 30)
                                                .clipShape(Circle())
                                        }
                                        
                                        Text (site.siteName)
                                            .font(.caption)
                                    }
                                    .frame(width: 70, height: 48)
                                    .padding(.vertical, 2)
                                }
                                .id(idx)
                                .padding(.vertical, 4)
                                .animation(.easeInOut, value: selectedIndex)

                                
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .clipShape(Capsule())
                .background(Color.gray.gradient.opacity(0.94))
                .cornerRadius(20)
                .onChange(of: selectedIndex) {
                    withAnimation(.easeInOut) {
                        proxy.scrollTo(selectedIndex, anchor: .center)
                        CombineRepo.shared.selectWebView.send(selectedIndex)
                    }
                }
                .onAppear {
                    print("Scrolling to marker")
                        withAnimation(.easeInOut) {
                            proxy.scrollTo(selectedIndex, anchor: .center)
                    }
                }
            }
            .frame(height: 42)
            .coordinateSpace(name: "scroll")

            
        }
    }
}




struct AnyViewModifier: ViewModifier {
    let bodyModifier: (Content) -> AnyView
    init<V: View>(@ViewBuilder _ bodyModifier: @escaping (Content) -> V) {
        self.bodyModifier = { AnyView(bodyModifier($0)) }
    }
    func body(content: Content) -> some View {
        bodyModifier(content)
    }
}





