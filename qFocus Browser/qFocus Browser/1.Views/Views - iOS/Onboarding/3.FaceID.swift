//
//  FaceID.swift
//  qFocus Browser
//
//
import SwiftUI
import FactoryKit



struct FaceID: View {
    @InjectedObject(\.faceIDVM) var viewModel: FaceIDVM


    var body: some View {
        
        VStack(spacing: 30) {
            
            Text("onboarding.030faceid.text")
                .multilineTextAlignment(.center)
                .lineSpacing(8)

            Spacer().frame(height: 10)

            Button {
                viewModel.enableFaceID()
            } label: {
                Text("onboarding.030faceid.button")
                    .foregroundColor(.white)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 16)
            }
            .glassEffect(.regular.tint(.blue))
            
            Spacer().frame(height: 10)
            
            Image(systemName: "faceid")
                .font(.system(size: 150))
                .foregroundColor(.blue)
                .buttonStyle(.glass)
            
            Spacer()
            
        }
    }
}

