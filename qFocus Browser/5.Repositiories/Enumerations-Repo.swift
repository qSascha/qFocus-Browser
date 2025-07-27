//
//  Enumerations-Repo.swift
//  qFocus Browser
//
//
import UIKit



@MainActor
class DeviceInfo {
    static let shared = DeviceInfo()

    let platform: AppPlatform

    private init() {
#if os(iOS)
        let device = UIDevice.current.userInterfaceIdiom
        self.platform = device == .pad ? .iPadOS : .iOS
#elseif os(macOS)
        self.platform = .macOS
#elseif os(visionOS)
        self.platform = .visionOS
#else
        self.platform = .iOS
#endif
    }
}
