//
//  Helpers-UC.swift
//  qFocus Browser
//
//

import UIKit
import SwiftUI



//MARK: App Version
let appVersion = "25.06"
let copyRightYear = "2025"



//MARK: generateBlueSystemImage
func generateBlueSystemImage(named systemName: String, size: CGFloat = 32) -> UIImage? {
    let config = UIImage.SymbolConfiguration(pointSize: size, weight: .regular)
    guard let image = UIImage(systemName: systemName, withConfiguration: config)?
            .withRenderingMode(.alwaysOriginal) else { return nil }

    let renderer = UIGraphicsImageRenderer(size: image.size)
    return renderer.image { _ in
        UIColor.blue.set()
        image.draw(at: .zero)
    }
}



// MARK: ShareSheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {

        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}



//MARK: FQDN Only
func fqdnOnly(from url: String) -> String {
    return url.replacingOccurrences(of: "https://", with: "")
              .replacingOccurrences(of: "http://", with: "")
}



//MARK: Get Domain Core
func getDomainCore(_ host: String) -> String {
    let components = host.lowercased().split(separator: ".")
    guard components.count >= 2 else { return host.lowercased() }
    let mainDomain = components.suffix(2).joined(separator: ".")
    return mainDomain
}



//MARK: Identifable URL
struct IdentifiableURL: Identifiable {
    let id = UUID()
    let url: URL
}


