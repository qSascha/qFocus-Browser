//
//  Photos.swift
//  qFocus Browser
//
//
import SwiftUI
import FactoryKit



struct Photos: View {
    @InjectedObject(\.onboardingVM) var viewModel: OnboardingVM


    var body: some View {
        if #available(iOS 26.0, *) {
            
            VStack(spacing: 10) {
                
                Text("onboarding.040photos.text")
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                
                Spacer().frame(height: 20)
                
                
                Button {
                    viewModel.requestPhotoAccess()
                } label: {
                    Text("onboarding.040photos.button")
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                }
                .glassEffect(.regular.tint(.blue))
                .padding(.trailing, 20)
                .padding(.top, 10)
                
                
                HStack(alignment: .top, spacing: 10) {
                    // Symbol at the top left of the text
                    switch viewModel.pictureAccessLevel {
                    case .denied:
                        Image(systemName: "exclamationmark.shield.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40)
                            .foregroundColor(.red)
                            .padding(.trailing, 6)
                            .padding(.top, 2)
                    case .limited:
                        Image(systemName: "checkmark.circle.trianglebadge.exclamationmark.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40)
                            .foregroundColor(.orange)
                            .padding(.trailing, 6)
                            .padding(.top, 2)
                    case .full:
                        Image(systemName: "checkmark.seal.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40)
                            .foregroundColor(.green)
                            .padding(.trailing, 6)
                            .padding(.top, 2)
                    case .unknown:
                        EmptyView()
                    default:
                        Image(systemName: "questionmark.app.dashed")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40)
                            .foregroundColor(.blue)
                            .padding(.trailing, 6)
                            .padding(.top, 2)
                    }
                    // VStack for text, so text stays left-aligned
                    VStack(alignment: .leading, spacing: 4) {
                        switch viewModel.pictureAccessLevel {
                        case .denied:
                            Text("onboarding.040photos.denied")
                                .font(.caption)
                        case .limited:
                            Text("onboarding.040photos.limited")
                                .font(.caption)
                        case .full:
                            Text("onboarding.040photos.full")
                                .font(.caption)
                        case .unknown:
                            Text("")
                                .font(.caption)
                        default:
                            Text("onboarding.040photos.denied")
                                .font(.caption)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 30)
                .padding(.top, 8)
                .multilineTextAlignment(.leading)
                
                Spacer().frame(height: 20)
                
                Image("OnboardingPhotos")
                    .resizable()
                    .frame(width: 250, height: 250)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .gray.opacity(0.6), radius: 8, x: 8, y: 8)
                
                Spacer()
                
            }
            
        } else {
            // Legacy Versions
            VStack(spacing: 10) {
                
                Text("onboarding.040photos.text")
                    .multilineTextAlignment(.center)
                    .lineSpacing(8)
                
                Spacer().frame(height: 20)
                
                
                Button {
                    viewModel.requestPhotoAccess()
                } label: {
                    Text("onboarding.040photos.button")
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                }
                .background(Color.blue)
                .cornerRadius(20)
                .padding(.trailing, 20)
                .padding(.top, 10)
                
                
                HStack(alignment: .top, spacing: 10) {
                    // Symbol at the top left of the text
                    switch viewModel.pictureAccessLevel {
                    case .denied:
                        Image(systemName: "exclamationmark.shield.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40)
                            .foregroundColor(.red)
                            .padding(.trailing, 6)
                            .padding(.top, 2)
                    case .limited:
                        Image(systemName: "checkmark.circle.badge.xmark.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40)
                            .foregroundColor(.orange)
                            .padding(.trailing, 6)
                            .padding(.top, 2)
                    case .full:
                        Image(systemName: "checkmark.seal.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40)
                            .foregroundColor(.green)
                            .padding(.trailing, 6)
                            .padding(.top, 2)
                    case .unknown:
                        EmptyView()
                    default:
                        Image(systemName: "questionmark.app.dashed")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40)
                            .foregroundColor(.blue)
                            .padding(.trailing, 6)
                            .padding(.top, 2)
                    }
                    // VStack for text, so text stays left-aligned
                    VStack(alignment: .leading, spacing: 4) {
                        switch viewModel.pictureAccessLevel {
                        case .denied:
                            Text("onboarding.040photos.denied")
                                .font(.caption)
                        case .limited:
                            Text("onboarding.040photos.limited")
                                .font(.caption)
                        case .full:
                            Text("onboarding.040photos.full")
                                .font(.caption)
                        case .unknown:
                            Text("")
                                .font(.caption)
                        default:
                            Text("onboarding.040photos.denied")
                                .font(.caption)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 30)
                .padding(.top, 8)
                .multilineTextAlignment(.leading)
                
                Spacer().frame(height: 20)
                
                Image("OnboardingPhotos")
                    .resizable()
                    .frame(width: 250, height: 250)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .gray.opacity(0.6), radius: 8, x: 8, y: 8)
                
                Spacer()
                
            }

        }
        
    }
}

