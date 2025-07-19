//
//  HelperViews.swift
//  qFocus Browser
//
//
import SwiftUI



//MARK: It is Swedish - Bubble
struct ItIsSwedish: View {
    let textSize: CGFloat
    let bubbleWidth: CGFloat
    let bubbleHeight: CGFloat
    let offsetX: CGFloat
    let offsetY: CGFloat
    let textOffsetX: CGFloat
    let textOffsetY: CGFloat

    var body: some View {
        ZStack {
            Image(systemName: "bubble.fill")
                .resizable()
                .frame(width: bubbleWidth, height: bubbleHeight)
                .foregroundStyle(.blue)
                .shadow(radius: 1)

            Text("It's\nSwedish!")
                .font(.system(size: textSize, weight: .bold))
                .foregroundStyle(.yellow)
                .offset(x: textOffsetX, y: textOffsetY)
        }
        .offset(x: offsetX, y: offsetY)
    }
}

