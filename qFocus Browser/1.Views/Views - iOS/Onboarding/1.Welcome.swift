//
//  Welcome.swift
//  qFocus Browser
//
//
import SwiftUI



struct Welcome: View {
    var body: some View {

        VStack(spacing: 30) {

            Text("onboarding.010welcome.text")
                .multilineTextAlignment(.center)
                .lineSpacing(8)
            
            Spacer().frame(height: 40)
            
            Image("AppIcon")
                .resizable()
                .frame(width: 150, height: 150)

//            ItIsSwedish(textSize: 18, bubbleWidth: 100, bubbleHeight: 90, offsetX: 80, offsetY: -260, textOffsetX: 0, textOffsetY: -10)

            Spacer()
            
        }
    }
    
}
