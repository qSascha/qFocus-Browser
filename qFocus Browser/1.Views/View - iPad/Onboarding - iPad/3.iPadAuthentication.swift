//
//  iPadFaceID.swift
//  qFocus Browser
//
//
import SwiftUI
import FactoryKit



struct iPadAuthentication: View {
    @InjectedObject(\.authenticationVM) var viewModel: AuthenticationVM


    var body: some View {
        if #available(iOS 26.0, *) {

            VStack(spacing: 60) {
                // Header
                Text(viewModel.biometryHeader)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.top, 80)
                
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
                .glassEffect(.regular.tint(.blue))
                .padding(.trailing, 20)
                .padding(.top, 10)
                
                HStack(alignment: .top, spacing: 10) {
                    // Symbol at the top left of the text
                    if viewModel.authEnabled {
                        Image(systemName: "exclamationmark.shield.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40)
                            .foregroundColor(.green)
                            .padding(.trailing, 6)
                            .padding(.top, 2)

                        Text(viewModel.biometryTextEnabled)
                            .font(.caption)

                    } else {
                        Image(systemName: "exclamationmark.shield.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40)
                            .foregroundColor(.red)
                            .padding(.trailing, 6)
                            .padding(.top, 2)

                        Text(viewModel.biometryTextDisabled)
                            .font(.caption)

                    }
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 30)
                .padding(.top, 8)
                .multilineTextAlignment(.leading)

                Spacer().frame(height: 10)
                
                Image(systemName: viewModel.biometrySFSymbol)
                    .font(.system(size: 150))
                    .foregroundColor(.blue)
                    .buttonStyle(.glass)
                
                Spacer()
                
            }

        } else {
            // Legacy Version

            VStack(spacing: 60) {
                // Header
                Text(viewModel.biometryHeader)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                    .padding(.top, 80)

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
                
                HStack(alignment: .top, spacing: 10) {
                    // Symbol at the top left of the text
                    if viewModel.authEnabled {
                        Image(systemName: "exclamationmark.shield.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40)
                            .foregroundColor(.green)
                            .padding(.trailing, 6)
                            .padding(.top, 2)

                        Text(viewModel.biometryTextEnabled)
                            .font(.caption)

                    } else {
                        Image(systemName: "exclamationmark.shield.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40)
                            .foregroundColor(.red)
                            .padding(.trailing, 6)
                            .padding(.top, 2)

                        Text(viewModel.biometryTextDisabled)
                            .font(.caption)

                    }
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 30)
                .padding(.top, 8)
                .multilineTextAlignment(.leading)
                
                Spacer().frame(height: 10)
                
                Image(systemName: viewModel.biometrySFSymbol)
                    .font(.system(size: 150))
                    .foregroundColor(.blue)
                
                Spacer()
                
            }


        }

    }
}
