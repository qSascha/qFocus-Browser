//
//  Done.swift
//  qFocus Browser
//
//
import SwiftUI



struct Done: View {
    var body: some View {
        
        VStack(spacing: 30) {
            Text("onboarding.070done.text")
                .multilineTextAlignment(.center)
                .lineSpacing(8)
            
            Spacer().frame(height: 20)
            
            Image(systemName: "checkmark.bubble.rtl")
                .font(.system(size: 150))
                .foregroundColor(.blue)
            
            Spacer()
        }
    }
}

