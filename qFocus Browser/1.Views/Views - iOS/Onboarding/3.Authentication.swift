//
//  Authentication.swift
//  qFocus Browser
//
//
import SwiftUI
import FactoryKit



struct Authentication: View {
    @InjectedObject(\.authenticationVM) var viewModel: AuthenticationVM


    var body: some View {
        if #available(iOS 26.0, *) {

            VStack(spacing: 50) {
                // Header
                Text(viewModel.biometryHeader)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.top, 40)
                
                Text(viewModel.biometryText)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(8)
                
                Button {
                    viewModel.enableFaceID()
                } label: {
                    Text(viewModel.biometryTextButton)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                }
                .glassEffect(.regular.tint(.blue))
                
                HStack(alignment: .center, spacing: 10) {
                    // Symbol at the top left of the text
                    if viewModel.authEnabled {
                        Image(systemName: "exclamationmark.shield.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40)
                            .foregroundColor(.green)
                            .padding(.trailing, 6)

                        Text(viewModel.biometryTextEnabled)
                            .font(.caption)

                    } else {
                        Image(systemName: "exclamationmark.shield.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40)
                            .foregroundColor(.red)
                            .padding(.trailing, 6)

                        Text(viewModel.biometryTextDisabled)
                            .font(.caption)

                    }
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.top, -30)
                .padding(.horizontal, 30)
                .multilineTextAlignment(.leading)
                
                Image(systemName: viewModel.biometrySFSymbol)
                    .font(.system(size: 150))
                    .foregroundColor(.blue)
                
                Spacer()
                
            }
            .padding(.horizontal, 20)

        } else {
            // Legacy Version

            VStack(spacing: 50) {
                
                Text(viewModel.biometryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)

                Button {
                    viewModel.enableFaceID()
                } label: {
                    Text(viewModel.biometryTextButton)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                }
                .background(Color.blue)
                .cornerRadius(20)
                
                HStack(alignment: .center, spacing: 10) {
                    // Symbol at the top left of the text
                    if viewModel.authEnabled {
                        Image(systemName: "exclamationmark.shield.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40)
                            .foregroundColor(.green)
                            .padding(.trailing, 6)

                        Text(viewModel.biometryTextEnabled)
                            .font(.caption)

                    } else {
                        Image(systemName: "exclamationmark.shield.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40)
                            .foregroundColor(.red)
                            .padding(.trailing, 6)

                        Text(viewModel.biometryTextDisabled)
                            .font(.caption)

                    }
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 30)
                .padding(.top, -30)
                .multilineTextAlignment(.leading)
                
                Image(systemName: viewModel.biometrySFSymbol)
                    .font(.system(size: 150))
                    .foregroundColor(.blue)
                
                Spacer()
                
            }
            .padding(.horizontal, 20)

        }

    }
}

