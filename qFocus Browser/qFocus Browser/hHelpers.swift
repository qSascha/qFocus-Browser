//
//  hHelpers.swift
//  qFocus Browser
//
//  Created by Sascha on 2024-12-08.
//

import Foundation
import SwiftUI

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif






class GlobalVariables: ObservableObject {
    
    @Published var currentTab: Int = 0
    @Published var previousTab: Int = 0
    @Published var nextTab: Int = 1
    @Published var onboardingStep: Int = 1
    @Published var onboardingFirstSiteOK: Bool = false
    @Published var tempSiteName: String = ""
    @Published var tempSiteURL: String = ""
    @Published var tempSiteFavIcon: Data? = nil
    @Published var backupIcon: Data? = nil
    
}




// Convert an Image to Data
@MainActor
extension Image {
    func asUIImage() -> UIImage? {
        let renderer = ImageRenderer(content: self)
        return renderer.uiImage
    }
    
    func asPNGData() -> Data? {
        let renderer = ImageRenderer(content: self)
        return renderer.uiImage?.pngData()
    }
}




#if os(iOS)
    
func isiPad() -> Bool {
    return UIDevice.current.userInterfaceIdiom == .pad
}

#endif




