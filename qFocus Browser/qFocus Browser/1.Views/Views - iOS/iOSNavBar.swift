//
//  iOSNavBar.swift
//  qFocus Browser
//
//
import SwiftUI
import FactoryKit


/*
struct NavBar: View {
    @InjectedObject(\.navigationVM) var viewModel: NavigationVM

    @ObservedObject var coordinator: AppCoordinator

    
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                // ***** Invisible box to push button to the right *****
                Rectangle()
                    .opacity(0)
                    .frame(width: 10, height: 10)

                Button(action: {
                    coordinator.showOptionsView.toggle()
                }) {
                    Image(systemName: "slider.horizontal.3")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                        .frame(width: (viewModel.menuIconSize * 0.75), height: (viewModel.menuIconSize * 0.75), alignment: .center)
                }

                Spacer()

                ForEach(viewModel.webSites.map { $0 }, id: \.objectID) { site in
                    MenuButton(
                        index: viewModel.webSites.firstIndex(of: site) ?? 0,
                        webSites: viewModel.webSites,
                        menuIconSize: viewModel.menuIconSize
                    ) {
                        CombineRepo.shared.selectWebView.send(viewModel.webSites.firstIndex(of: site) ?? 0)
                    }
                    Spacer()
                }

                Button(action: {
                    coordinator.showShareSheet.toggle()
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                        .frame(width: (viewModel.menuIconSize * 0.75), height: (viewModel.menuIconSize * 0.75), alignment: .center)
                }

                // ***** Invisible box to push button to the left *****
                Rectangle()
                    .opacity(0)
                    .frame(width: 10, height: 10)
            }
            .frame(maxWidth: .infinity, maxHeight: 30)
            .background(Color(.qBlueLight))
            
            Spacer()
        }
        .zIndex(5)
        .onAppear {
#if DEBUG
            print("Showing NavBar")
#endif

        }
    }
}
*/
