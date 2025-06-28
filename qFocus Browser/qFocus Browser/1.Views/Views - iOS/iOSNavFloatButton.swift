//
//  iOSNavFloatButton.swift
//  qFocus Browser
//
//

/*
import SwiftUI
import FactoryKit



struct FloatingNavBar: View {
    @InjectedObject(\.navigationVM) var viewModel: NavigationVM

    @ObservedObject var coordinator: AppCoordinator

    @GestureState private var isDragging = false
    @GestureState private var isLongPressing = false
    
    let pressFeedback = UIImpactFeedbackGenerator(style: .rigid)
    let tapFeedback = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
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
 
                .position(
                    x: viewModel.updateXPercent * geometry.size.width,
                    y: viewModel.updateYPercent * geometry.size.height
                )

                .onTapGesture {
                    withAnimation(.spring()) {
                        viewModel.isShowingMenu.toggle()
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

                // Popup window with navigation buttons
                if viewModel.isShowingMenu {
                    FloatMenu(coordinator: coordinator)
                }

            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .zIndex(8)
        
    }
}

*/

