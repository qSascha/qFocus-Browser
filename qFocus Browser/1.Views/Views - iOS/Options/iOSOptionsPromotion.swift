//
//  iOSPromotion.swift
//  qFocus Browser
//
//
import SwiftUI
import FactoryKit



struct iOSPromotion: View {
    @InjectedObject(\.optionsVM) var optionsVM: OptionsVM


    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                
                // Top Section, with buttons
                VStack(alignment: .leading, spacing: 10) {
                    Spacer()
                    // KoFi button
                    HStack {
                        Spacer()
                        
                        Image(uiImage: UIImage(named: "Promotion-button-KoFi")!)
                            .resizable()
                            .frame(width: 200, height: 56)
                            .cornerRadius(28)
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                            .onTapGesture {
                                optionsVM.externalURL = IdentifiableURL(url: URL(string: "https://ko-fi.com/R6R519DHVF")!)
                            }
                        
                        Spacer()
                    }
                    Spacer()
                    // BMC button
                    HStack {
                        Spacer()
                        
                        Image(uiImage: UIImage(named: "Promotion-button-BMC")!)
                            .resizable()
                            .frame(width: 200, height: 56)
                            .cornerRadius(28)
                            .overlay(
                                RoundedRectangle(cornerRadius: 28)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                            .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                            .onTapGesture {
                                optionsVM.externalURL = IdentifiableURL(url: URL(string: "https://buymeacoffee.com/qsascha")!)
                            }
                        
                        
                        Spacer()
                    }
                    Spacer()
                }
                
                // Text 1
                InteractiveLocalizedText(text: String(localized: ("promotion.text")))
                
                // Bottom Secction, with image
                HStack {
                    
                    //Left column, text
//                    VStack {
                        Text("promotion.text2")
                            .lineSpacing(8)
                            .padding(.leading, 30)
                        
//                    }
                    
                    //Right column, image
                    Spacer()
                    HStack {
                        
                        Spacer()
                        ZStack {
                            
                            Image(uiImage: UIImage(named: "Promotion-qSascha")!)
                                .resizable()
                                .frame(width: 130, height: 130)
                                .cornerRadius(75)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 75)
                                        .stroke(Color.gray, lineWidth: 1)
                                )
                                .onTapGesture {
                                    optionsVM.externalURL = IdentifiableURL(url: URL(string: "https://qsascha.dev")!)
                                }
                            
                            ItIsSwedish(textSize: 10, bubbleWidth: 64, bubbleHeight: 55, offsetX: 40, offsetY: -75, textOffsetX: 0, textOffsetY: -7)
                            
                        }
                        Spacer()
                    }
                    
                }
                
                // Text 3
                InteractiveLocalizedText(text: String(localized: ("promotion.text3")))

                Spacer(minLength: 40)
                
            }
        }
        .onAppear() {
            Collector.shared.save(event: "Viewed", parameter: "Options-Promotion")
        }

    }

}




//MARK: Tap Sascha
// Functions to highlight and allow tap on "Sascha"
struct InteractiveLocalizedText: View {
    let text: String
    @InjectedObject(\.optionsVM) var optionsVM: OptionsVM


    var body: some View {
        Text(attributedPromotionText)
            .lineSpacing(8)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 30)
            .environment(\.openURL, OpenURLAction { url in
                // Open Link: Sascha
                if url.scheme == "action" && url.host == "tap-sascha" {
                    optionsVM.externalURL = IdentifiableURL(url: URL(string: "https://qsascha.dev")!)
                    return .handled
                }

                // Open Link: fika
                if url.scheme == "action" && url.host == "tap-fika" {
                    optionsVM.externalURL = IdentifiableURL(url: URL(string: "https://visitsweden.com/what-to-do/food-drink/swedish-kitchen/all-about-swedish-fika/")!)
                    Collector.shared.save(event: "ExternalBrowser", parameter: "Swedish Fika Link")
                    return .handled
                }

                return .discarded
            })
    }
    
    private var attributedPromotionText: AttributedString {
        var attributedString = AttributedString(text)

        // Trigger: Sascha (first occurrence only, to match original logic)
        if let range = attributedString.range(of: "Sascha") {
            attributedString[range].foregroundColor = .blue
            if let customURL = URL(string: "action://tap-sascha") {
                attributedString[range].link = customURL
            }
        }

        // Trigger: fika and Fika (ALL occurrences, both cases)
        for variant in ["fika", "Fika"] {
            var position = attributedString.startIndex
            while position < attributedString.endIndex,
                  let foundRange = attributedString[position...].range(of: variant) {
                attributedString[foundRange].foregroundColor = .blue
                if let customURL = URL(string: "action://tap-fika") {
                    attributedString[foundRange].link = customURL
                }
                position = foundRange.upperBound
            }
        }

        return attributedString
    }
}




struct InteractiveLocalizedTextModifier: ViewModifier {
    @Binding var navigateToSascha: Bool
//    let collector: Collector
    
    func body(content: Content) -> some View {
        content
            .environment(\.openURL, OpenURLAction { url in
                if url.scheme == "action" && url.host == "tap-sascha" {
                    navigateToSascha = true
                    return .handled
                }
                return .discarded
            })
    }
}

#Preview {
    iOSPromotion()
}

