//
//  macOSTabView.swift
//  qFocus Browser
//
//  Created by Sascha on 2024-12-08.
//

import SwiftUI



struct MyHoverButtonStyle: ButtonStyle {
    @State private var withHover = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(12)
            .foregroundStyle(.tint)
            .background {
                if withHover {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("macOStabSelect").opacity(0.5))
                        .scaleEffect(1.1)
                        .transition(.scale.animation(.easeInOut(duration: 0.1)))
                }
            }
            .onHover { isHovering in
                withHover = isHovering
            }
    }
}


public struct macOSTabView: View {
    private let titles: [String]
    private let tabViews: [AnyView]

    @State private var selection = 0
    @State private var indexHovered = -1
    @State private var withHover = false

    public init(content: [(title: String, view: AnyView)]) {
        self.titles = content.map{ $0.title }
        self.tabViews = content.map{ $0.view }
}
    
    public var tabBar: some View {
        VStack {
            Spacer()
            .frame(height: 4)
            .padding(.top, 4)
            
            HStack {
                Spacer()
                .frame(width: 3)
                .padding(.leading, 3)

                Button(action: {
                }, label: {
                    Image(systemName: "slider.horizontal.3")
                        .resizable()
                        .foregroundColor(.blue)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 18, height: 18, alignment: .center)
                })
                .buttonStyle(MyHoverButtonStyle())

                Button(action: {
                }, label: {
                    Image(systemName: "equal.square")
                        .resizable()
                        .foregroundColor(.blue)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 18, height: 18, alignment: .center)
                })
                .buttonStyle(MyHoverButtonStyle())


                Spacer()
                ForEach(0..<titles.count, id: \.self) { index in
                    
                    Text(self.titles[index])
                        .frame(height: 12)
                        .padding(12)
                        .foregroundColor(self.selection == index ? Color.blue : Color.blue)
                        .overlay {
                            if self.selection == index {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.blue, lineWidth: 1 )
                            }
                        }

                        .onTapGesture {
                            self.selection = index
                        }
                        .background {
                            if (withHover && self.indexHovered == index) {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color("macOStabSelect").opacity(0.5))
                                    .scaleEffect(1.1)
                                    .transition(.scale.animation(.easeInOut(duration: 0.1)))
                            }
                        }
                        .onHover { isHovering in
                            withHover = isHovering
                            self.indexHovered = index
                        }

                }
                Spacer()
            }
            .padding(3)
            .background(Color("background"))

            Spacer()
            .frame(height: 3)
            .padding(.leading, 3)

        }
        .background(Color("background"))

    }


public var body: some View {
    VStack(spacing: 0) {
        tabBar

        tabViews[selection]
            .padding(0)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(0)
    }
}


