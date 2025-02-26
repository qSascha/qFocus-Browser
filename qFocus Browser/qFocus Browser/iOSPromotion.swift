//
//  iOSPromotion.swift
//  qFocus Browser
//
//  Created by Sascha on 2025-02-23.
//
#if os(iOS)
import SwiftUI




struct iOSPromotion: View {

    @EnvironmentObject var collector: Collector

    

    var body: some View {

        VStack(alignment: .leading, spacing: 10) {
            
            // Top Section, with buttons
            VStack {
                Spacer()
                // KoFi button
                HStack {
                    Spacer()
                    
                    NavigationLink {
                        ExternalWebView(url: URL(string: "https://ko-fi.com/R6R519DHVF")!)
                    } label: {
                        Image(uiImage: UIImage(named: "Promotion-button-KoFi")!)
                            .resizable()
                            .frame(width: 200, height: 56)
                            .cornerRadius(28)
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    
                    Spacer()
                }
                Spacer()
                // BMC button
                HStack {
                    Spacer()
                    
                    NavigationLink {
                        ExternalWebView(url: URL(string: "https://buymeacoffee.com/qsascha")!)
                    } label: {
                        Image(uiImage: UIImage(named: "Promotion-button-BMC")!)
                            .resizable()
                            .frame(width: 200, height: 56)
                            .cornerRadius(28)
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                    }

                    Spacer()
                }
                Spacer()
            }

            // Main text
            InteractiveLocalizedText()
                .environmentObject(collector)

            // Bottom Secction, with image
            HStack {

                //Left column, text
                VStack {
                    Text("promotion.text2")
                        .lineSpacing(8)
                        .padding(.leading, 30)

                }
                
                //Right column, image
                HStack {
                    Spacer()
                    
                    NavigationLink {
                        ExternalWebView(url: URL(string: "https://qsascha.dev")!)
                    } label: {
                        
                        Image(uiImage: UIImage(named: "Promotion-qSascha")!)
                            .resizable()
                            .frame(width: 150, height: 150)
                            .cornerRadius(750)
                            .overlay(
                                RoundedRectangle(cornerRadius: 750)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                    }

                    Spacer()
                }
                
                
            }


            Spacer(minLength: 50)
            
        }
    }



}




//MARK: Tap Sascha
// Functions to highlight and allow tap on "Sascha"
struct InteractiveLocalizedText: View {
    @EnvironmentObject var collector: Collector
    @State private var shouldNavigateToSascha: Bool = false
    
    var body: some View {
        Text(attributedPromotionText)
            .lineSpacing(8)
            .padding(.horizontal, 30)
            .navigationDestination(isPresented: $shouldNavigateToSascha) {
                ExternalWebView(url: URL(string: "https://qsascha.dev")!)
            }
            .environment(\.openURL, OpenURLAction { url in
                if url.scheme == "action" && url.host == "tap-sascha" {
                    collector.save(event: "Promotion", parameter: "Tapped Sascha")
                    shouldNavigateToSascha = true
                    return .handled
                }
                return .discarded
            })
    }
    
    private var attributedPromotionText: AttributedString {
        var attributedString = AttributedString(localized: "promotion.text")
        
        if let range = attributedString.range(of: "Sascha") {
            attributedString[range].foregroundColor = .blue
            
            if let customURL = URL(string: "action://tap-sascha") {
                attributedString[range].link = customURL
            }
        }
        
        return attributedString
    }
}



struct InteractiveLocalizedTextModifier: ViewModifier {
    @Binding var navigateToSascha: Bool
    let collector: Collector
    
    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction { url in
                if url.scheme == "action" && url.host == "tap-sascha" {
                    collector.save(event: "Promotion", parameter: "Tapped Sascha")
                    navigateToSascha = true
                    return .handled
                }
                return .discarded
            })
    }
}




#endif

