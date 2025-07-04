//
//  iOSAuthFail.swift
//  qFocus Browser
//
//

import SwiftUI



struct iOSAuthFail: View {
    let retryAction: () -> Void

    var body: some View {
        VStack() {

            Text("Authentication Failed")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding(.vertical, 16)

            Image(systemName: "faceid")
                .font(.system(size: 96))
                .foregroundColor(.blue)
                .padding(.vertical, 16)

            Text("Face ID authentication was unsuccessful. Please try again.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
                .padding(.vertical, 16)

            Button(action: {
                retryAction()
            }) {
                Text("Retry")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 32)
            }
            .padding(.vertical, 16)

            Spacer()
        }
        .padding()
        .onAppear {
#if DEBUG
            print("⚠️ iOSAuthFail")
#endif
        }
    }
}


