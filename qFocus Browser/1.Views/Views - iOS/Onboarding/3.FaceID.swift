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
        if #available(iOS 26.0, *) {

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
                .padding(.trailing, 20)
                .padding(.top, 10)
                
                HStack(alignment: .top, spacing: 10) {
                    // Symbol at the top left of the text
                    if viewModel.faceIDEnabled {
                        Image(systemName: "exclamationmark.shield.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40)
                            .foregroundColor(.green)
                            .padding(.trailing, 6)
                            .padding(.top, 2)

                        Text("onboarding.030faceID.enabled")
                            .font(.caption)

                    } else {
                        Image(systemName: "exclamationmark.shield.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40)
                            .foregroundColor(.red)
                            .padding(.trailing, 6)
                            .padding(.top, 2)

                        Text("onboarding.030faceID.disabled")
                            .font(.caption)

                    }
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 30)
                .padding(.top, 8)
                .multilineTextAlignment(.leading)

                Spacer().frame(height: 10)
                
                Image(systemName: "faceid")
                    .font(.system(size: 150))
                    .foregroundColor(.blue)
                    .buttonStyle(.glass)
                
                Spacer()
                
            }

        } else {
            // Legacy Version

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
                .background(Color.blue)
                .cornerRadius(20)
                
                
                HStack(alignment: .top, spacing: 10) {
                    // Symbol at the top left of the text
                    if viewModel.faceIDEnabled {
                        Image(systemName: "exclamationmark.shield.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40)
                            .foregroundColor(.green)
                            .padding(.trailing, 6)
                            .padding(.top, 2)

                        Text("onboarding.030faceID.enabled")
                            .font(.caption)

                    } else {
                        Image(systemName: "exclamationmark.shield.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40)
                            .foregroundColor(.red)
                            .padding(.trailing, 6)
                            .padding(.top, 2)

                        Text("onboarding.030faceID.disabled")
                            .font(.caption)

                    }
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 30)
                .padding(.top, 8)
                .multilineTextAlignment(.leading)
                
                Spacer().frame(height: 10)
                
                Image(systemName: "faceid")
                    .font(.system(size: 150))
                    .foregroundColor(.blue)
                
                Spacer()
                
            }


        }

    }
}

