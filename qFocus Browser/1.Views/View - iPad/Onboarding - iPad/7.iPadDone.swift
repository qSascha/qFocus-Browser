//
//  iPadDone.swift
//  qFocus Browser
//
//
import SwiftUI



struct iPadDone: View {
    var body: some View {
        
        VStack(spacing: 60) {
            // Header
            Text("onboarding.070done.header")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding(.top, 40)
            
            Text("onboarding.070done.text")
                .multilineTextAlignment(.center)
                .lineSpacing(8)
            
            Image(systemName: "checkmark.bubble.rtl")
                .font(.system(size: 150))
                .foregroundColor(.blue)
            
            Spacer()
        }
    }
}

