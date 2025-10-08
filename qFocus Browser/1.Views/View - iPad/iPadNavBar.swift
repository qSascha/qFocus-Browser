//
//  iPadNavBar.swift
//  qFocus Browser
//
//
import SwiftUI
import FactoryKit



struct iPadNavBar: View {
    @InjectedObject(\.navigationVM) var viewModel: NavigationVM
    
    @ObservedObject var coordinator: AppCoordinator
    @Namespace var navBarAnimation
    
    @GestureState private var isDragging = false
    @GestureState private var isLongPressing = false
    
    let pressFeedback = UIImpactFeedbackGenerator(style: .rigid)
    let tapFeedback = UIImpactFeedbackGenerator(style: .medium)

    
    
    var body: some View {
        GeometryReader { geometry in
            if #available(iOS 26.0, *) {
                
                ZStack {
                    if viewModel.minimizeNavBar {
/*
                        //MARK: Button Minimized
                        Button {
                            viewModel.minimizeNavBar = false
                        } label: {
*/
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
                            
//                        }
                        .glassEffect()
                        .matchedGeometryEffect(id: "navBar", in: navBarAnimation)
                        .scaleEffect(isDragging || isLongPressing ? 1.1 : 1.0)
         
                        .position(
                            x: viewModel.updateXPercent * geometry.size.width,
                            y: viewModel.updateYPercent * geometry.size.height
                        )

                        .onTapGesture {
                            withAnimation(.spring()) {
                                viewModel.minimizeNavBar = false
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
                                            viewModel.updateFreeFlowXYPercent(newXPercent, newYPercent, save: false)

                                        }
                                    }

                                    .onEnded { gesture in
                                        pressFeedback.impactOccurred(intensity: 0.5)
                                        let newXPercent = Double(gesture.location.x / geometry.size.width)
                                        let newYPercent = Double(gesture.location.y / geometry.size.height)
                                        viewModel.updateFreeFlowXYPercent(newXPercent, newYPercent, save: true)
                                    }
                                               )
                        )
                        .animation(.interactiveSpring(), value: isDragging)

                        
                    } else {
                        
                        HStack(alignment: .center) {
                            
                            //MARK: Button Options
                            Button(action: {
                                viewModel.minimizeNavBar = true
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
                            
                            //MARK: Button ShareSheet
                            Button(action: {
                                viewModel.minimizeNavBar = true
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
                        .matchedGeometryEffect(id: "navBar", in: navBarAnimation)
                        .position(
                            x: geometry.size.width * 0.5, // Full width, centered horizontally
                            y: geometry.size.height * viewModel.updateYPercent
                        )
                        
                    }
                }
                .animation(.easeInOut(duration: 0.35), value: viewModel.minimizeNavBar)
                
            } else {
                
                //Legacy Version
                ZStack {
                    if viewModel.minimizeNavBar {
/*
                        //MARK: Legacy Button Minimized
                        Button {
                            viewModel.minimizeNavBar = false
                        } label: {
*/
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
                            
//                        }
                        .background(Color.gray.gradient.opacity(0.94))
                        .cornerRadius(20)
                        .matchedGeometryEffect(id: "navBar", in: navBarAnimation)
                        .scaleEffect(isDragging || isLongPressing ? 1.1 : 1.0)
         
                        .position(
                            x: viewModel.updateXPercent * geometry.size.width,
                            y: viewModel.updateYPercent * geometry.size.height
                        )

                        .onTapGesture {
                            withAnimation(.spring()) {
                                viewModel.minimizeNavBar = false
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
                                            viewModel.updateFreeFlowXYPercent(newXPercent, newYPercent, save: false)

                                        }
                                    }

                                    .onEnded { gesture in
                                        pressFeedback.impactOccurred(intensity: 0.5)
                                        let newXPercent = Double(gesture.location.x / geometry.size.width)
                                        let newYPercent = Double(gesture.location.y / geometry.size.height)
                                        viewModel.updateFreeFlowXYPercent(newXPercent, newYPercent, save: true)
                                    }
                                               )
                        )
                        .animation(.interactiveSpring(), value: isDragging)
                        
                    } else {
                        
                        HStack(alignment: .center) {
                            
                            //MARK: Legacy Button Options
                            Button(action: {
                                viewModel.minimizeNavBar = true
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
                            
                            //MARK: Legacy Button ShareSheet
                            Button(action: {
                                viewModel.minimizeNavBar = true
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
                        .matchedGeometryEffect(id: "navBar", in: navBarAnimation)
                        .position(
                            x: geometry.size.width * 0.5, // Full width, centered horizontally
                            y: geometry.size.height * viewModel.updateYPercent
                        )
                        
                    }
                }
                .animation(.easeInOut(duration: 0.35), value: viewModel.minimizeNavBar)
            }
        }
    }
}



//MARK: WebSite Selector View
struct iPadWebsiteSelectorView: View {
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
                                
                                //MARK: Button Select Site
                                Button(action: {
                                    selectedIndex = idx
                                    withAnimation(.easeInOut) {
                                        proxy.scrollTo(idx, anchor: .center)
                                    }

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
                    viewModel.minimizeNavBar = true
                    mainVM.updateTopAreaColor()
                    withAnimation(.easeInOut) {
                        proxy.scrollTo(selectedIndex, anchor: .center)
                    }
                    CombineRepo.shared.selectWebView.send(selectedIndex)
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
                                
                                //MARK: Legacy Button: Select Site
                                Button(action: {
                                    selectedIndex = idx
                                    withAnimation(.easeInOut) {
                                        proxy.scrollTo(idx, anchor: .center)
                                    }
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
                    viewModel.minimizeNavBar = true
                    withAnimation(.easeInOut) {
                        proxy.scrollTo(selectedIndex, anchor: .center)
                    }
                    CombineRepo.shared.selectWebView.send(selectedIndex)
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




struct iPadAnyViewModifier: ViewModifier {
    let bodyModifier: (Content) -> AnyView
    init<V: View>(@ViewBuilder _ bodyModifier: @escaping (Content) -> V) {
        self.bodyModifier = { AnyView(bodyModifier($0)) }
    }
    func body(content: Content) -> some View {
        bodyModifier(content)
    }
}





