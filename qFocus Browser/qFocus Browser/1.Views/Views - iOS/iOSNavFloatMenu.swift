//
//  iOSNavFloatMenu.swift
//  qFocus Browser
//
//
/*
import SwiftUI
import FactoryKit



struct FloatMenu: View {
    @InjectedObject(\.navigationVM) var viewModel: NavigationVM

    @ObservedObject var coordinator: AppCoordinator



    var body: some View {
        GeometryReader { geometry in
            
            HStack {
                VStack {
                    HStack {
                        ForEach(viewModel.webSites.indices, id: \.self) { index in
                            if index % 2 == 0 {
                                MenuButton(
                                    index: index,
                                    webSites: viewModel.webSites,
                                    menuIconSize: viewModel.menuIconSize
                                ) {
                                    CombineRepo.shared.selectWebView.send(index)
                                    viewModel.isShowingMenu = false
                                }
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 3, trailing: 5))
                    
                    HStack {
                        ForEach(viewModel.webSites.indices, id: \.self) { index in
                            if index % 2 != 0 {
                                MenuButton(
                                    index: index,
                                    webSites: viewModel.webSites,
                                    menuIconSize: viewModel.menuIconSize
                                ) {
                                    CombineRepo.shared.selectWebView.send(index)
                                    viewModel.isShowingMenu = false
                                }
                            }
                        }
                    }
                    .padding(EdgeInsets(top: 3, leading: 10, bottom: 10, trailing: 5))
                }
                
                VStack {
                    // Trigger to show Share Sheet
                    Button(action: {
                        coordinator.showShareSheet.toggle()
                        viewModel.isShowingMenu = false
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: (viewModel.menuIconSize * 0.75), height: (viewModel.menuIconSize * 0.75), alignment: .center)
                            .foregroundColor(.white)
                            .padding(EdgeInsets(top: 14, leading: 10, bottom: 7, trailing: 10))
                    }
                    
                    // Trigger to show options view
                    Button(action: {
                        coordinator.showOptionsView.toggle()
                        viewModel.isShowingMenu = false
                    }) {
                        Image(systemName: "slider.horizontal.3")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: (viewModel.menuIconSize * 0.75), height: (viewModel.menuIconSize * 0.75), alignment: .center)
                            .foregroundColor(.white)
                            .padding(EdgeInsets(top: 7, leading: 10, bottom: 14, trailing: 10))
                    }
                }
                .background(Color(.qBlueDark))
            }
            .background(Color(.qBlueLight))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 10)
            
            .position(
                x: min(max(viewModel.updateXPercent * geometry.size.width, 100), geometry.size.width - 100),
                y: min(max(viewModel.updateYPercent * geometry.size.height - 100, 100), geometry.size.height - 100)
            )
            
            .transition(.scale.combined(with: .opacity))
            
        }
    }
}
*/
