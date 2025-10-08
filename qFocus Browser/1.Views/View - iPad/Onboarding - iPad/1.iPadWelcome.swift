//
//  iPadWelcome.swift
//  qFocus Browser
//
//
import SwiftUI



struct iPadWelcome: View {
    var body: some View {

        VStack(spacing: 30) {
            // Header
            Text(String(localized: "onboarding.010welcome.header"))
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding(.top, 80)
            
            Spacer().frame(height: 40)

            Text("onboarding.010welcome.text")
                .multilineTextAlignment(.center)
                .lineSpacing(8)
            
            Spacer().frame(height: 40)
            
            Image("AppIcon")
                .resizable()
                .frame(width: 150, height: 150)

            Spacer()
            
        }
    }
    
}
