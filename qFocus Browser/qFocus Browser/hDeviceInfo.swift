//
//  hDeviceInfo.swift
//  qFocus Browser
//
//  Created by Sascha on 2025-02-23.
//
import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

class DeviceInfo {
    static func getDeviceIdentifier() -> String {
        #if os(iOS)
            let device = UIDevice.current
            let deviceType = UIDevice.current.userInterfaceIdiom == .pad ? "iPad" : "iPhone"
            return "\(deviceType) iOS \(device.systemVersion)"
        #elseif os(macOS)
            let osVersion = ProcessInfo.processInfo.operatingSystemVersion
            return "Mac macOS \(osVersion.majorVersion).\(osVersion.minorVersion)"
        #else
            return "Unknown Device"
        #endif
    }
}
