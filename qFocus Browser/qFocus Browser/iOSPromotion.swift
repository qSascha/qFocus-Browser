//
//  iOSPromotion.swift
//  qFocus Browser
//
//  Created by Sascha on 2025-02-23.
//
#if os(iOS)
import SwiftUI




struct iOSPromotion: View {
//    @EnvironmentObject var collector: Collector
    
    @State private var showKoFi: Bool = false
    @State private var showBMC: Bool = false
    @State private var showQSascha: Bool = false

    @EnvironmentObject var collector: Collector

    

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                
                // Image qSascha
                HStack {
                    Spacer()
                    
                    Image(uiImage: UIImage(named: "Promotion-qSascha")!)
                        .resizable()
                        .frame(width: 200, height: 200)
                        .cornerRadius(100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 100)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                        .onTapGesture {
                            showQSascha = true
                        }
                        .fullScreenCover(isPresented: $showQSascha) {
                            ExternalWebViewWrapper(url: URL(string: "https://qsascha.dev")!)
                        }

                    Spacer()
                }
                
                InteractiveLocalizedText()
                    .handlePromotionTaps(collector: collector)

              

                HStack {

                    //Left column
                    VStack {
                        Text("promotion.text2")
//                            .multilineTextAlignment(.center)
                            .lineSpacing(8)
                            .padding(.leading, 30)

                    }
                    
                    
                    
                    //Right column
                    VStack {
                        
                        Spacer()
                        
                        // KoFi button
                        HStack {
                            Spacer()
                            
                            Image(uiImage: UIImage(named: "Promotion-button-KoFi")!)
                                .resizable()
                                .frame(width: 150, height: 42)
                                .cornerRadius(21)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 21)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                                .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                                .onTapGesture {
                                    showKoFi = true
                                }
                                .fullScreenCover(isPresented: $showKoFi) {
                                    ExternalWebViewWrapper(url: URL(string: "https://buymeacoffee.com/qsascha")!)
                                }
                            
                            Spacer()
                        }
                        
                        Spacer()
                        
                        // BMC button
                        HStack {
                            Spacer()
                            
                            Image(uiImage: UIImage(named: "Promotion-button-BMC")!)
                                .resizable()
                                .frame(width: 150, height: 42)
                                .cornerRadius(21)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 21)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                                .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                                .onTapGesture {
                                    showBMC = true
                                }
                                .fullScreenCover(isPresented: $showBMC) {
                                    ExternalWebViewWrapper(url: URL(string: "https://buymeacoffee.com/qsascha")!)
                                }
                            
                            Spacer()
                        }
                        
                        Spacer()
                        
                    }
                    
                    
                }


                Spacer(minLength: 50)
                
            }
        }



    }
}





//MARK: Tap Sascha
// Functions to highlight and allow tap on "Sascha"
struct InteractiveLocalizedText: View {
    @EnvironmentObject var collector: Collector
    
    var body: some View {
        Text(attributedPromotionText)
//            .multilineTextAlignment(.center)
            .lineSpacing(8)
            .padding(.horizontal, 30)
    }
    
    private var attributedPromotionText: AttributedString {
        var attributedString = AttributedString( localized: "promotion.text")
        
        // Find the range of "Sascha" in the text
        if let range = attributedString.range(of: "Sascha") {
            attributedString[range].foregroundColor = .blue
//            attributedString[range].underlineStyle = .single
            
            // Add tap action data
            if let customURL = URL(string: "action://tap-sascha") {
                attributedString[range].link = customURL
            }
        }
        
        return attributedString
    }
}


struct InteractiveLocalizedTextModifier: ViewModifier {
    @State private var showQSascha: Bool = false
    let collector: Collector
    
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $showQSascha) {
                ExternalWebViewWrapper(url: URL(string: "https://qsascha.dev")!)
            }
            .environment(\.openURL, OpenURLAction { url in
                if url.scheme == "action" && url.host == "tap-sascha" {
                    collector.save(event: "Promotion", parameter: "Tapped Sascha")
                    
                    showQSascha = true

                    return .handled
                }
                return .discarded
            })
    }
}

extension View {
    func handlePromotionTaps(collector: Collector) -> some View {
        self.modifier(InteractiveLocalizedTextModifier(collector: collector))
    }
}





#endif

