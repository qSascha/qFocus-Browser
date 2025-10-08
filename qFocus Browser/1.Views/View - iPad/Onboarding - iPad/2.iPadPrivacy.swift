//
//  iPadPrivacy.swift
//  qFocus Browser
//
//
import SwiftUI



struct iPadPrivacy: View {
    var body: some View {
        
        VStack(spacing: 60) {
            // Header
            Text(String(localized: "onboarding.020privacy.header"))
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding(.top, 80)
                        
            Text("onboarding.020privacy.text")
                .multilineTextAlignment(.center)
                .lineSpacing(8)
            
            Image("OnboardingPrivacy")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 150)
            
            Spacer()
            
        }
    }
}
