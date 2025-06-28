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
            
            Spacer().frame(height: 20)
            
            Image("OnboardingWelcome")
                .resizable()
                .frame(width: 150, height: 150)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
            
            Spacer()
            
        }
    }
    
}
