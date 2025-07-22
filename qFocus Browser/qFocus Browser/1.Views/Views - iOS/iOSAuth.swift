//
//  iOSAuth.swift
//  qFocus Browser
//
//

import SwiftUI



struct iOSAuth: View {
    @StateObject private var viewModel = AuthenticationVM()

//    let completion: (Bool) -> Void
    let completion: @Sendable (Bool) -> Void

    var body: some View {

        VStack() {

            Text("Authentication Required")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.vertical, 16)

            Image(systemName: "faceid")
                .font(.system(size: 96))
                .foregroundColor(.blue)
                .padding(.vertical, 16)

            Text("FaceID is required to access qFocus Browser.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)


            Spacer()
        }
        .padding()
        .onAppear {
            #if DEBUG
            print("⚠️ iOSAuth")
            #endif
            viewModel.attemptFaceID { success in
                self.completion(success)
            }
        }
    }
}

