//
//  dataStorage.swift
//  qFocus Browser
//
//  Created by Sascha on 2024-12-11.
//

import SwiftData
import SwiftUI





@Model
class settingsStorage {
    var id: UUID = UUID()
    var navOnTop: Bool = false
    var hideSideIcons: Bool = false
    var hideMainIcons: Bool = false
    var bigIcons: Bool = false
    var opacity: Double = 0.7
    var enableAdBlock: Bool = true
    
    init(navOnTop: Bool, hideSideIcons: Bool, hideMainIcons: Bool, bigIcons: Bool, opacity: Double, enableAdBlock: Bool) {
        self.navOnTop = navOnTop
        self.hideSideIcons = hideSideIcons
        self.hideMainIcons = hideMainIcons
        self.bigIcons = bigIcons
        self.opacity = opacity
        self.enableAdBlock = enableAdBlock
    }
    
}




@Model
class sitesStorage {
    var id: UUID = UUID()
    var siteOrder: Int
    var siteName: String
    var siteURL: String

    @Attribute(.externalStorage)
    var siteFavIcon: Data?


    init(siteOrder: Int, siteName: String, siteURL: String, siteFavIcon: Data? = nil) {
        self.siteOrder = siteOrder
        self.siteName = siteName
        self.siteURL = siteURL
        self.siteFavIcon = siteFavIcon
    }
}

