//
//  Privacy.swift
//  qFocus Browser
//
//
import SwiftUI



struct Privacy: View {
    var body: some View {
        
        VStack(spacing: 30) {

            Text("onboarding.020privacy.text")
                .multilineTextAlignment(.center)
                .lineSpacing(8)
            
            Spacer().frame(height: 20)
            
            Image("OnboardingPrivacy")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 150)
            
            Spacer()
            
        }
    }
}
