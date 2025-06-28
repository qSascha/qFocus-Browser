//
//  MenuButton.swift
//  qFocus Browser
//
//
import SwiftUI


struct MenuButton: View {
    let index: Int
    let webSites: [SitesStorage]
    let menuIconSize: CGFloat
    let action: () -> Void


    
    var body: some View {
        let host = URL(string: webSites[index].siteURL)?.host ?? ""
//        let hasInjectedScript = greasyScripts.domainsWithInjectedScripts.contains(host)
        
        return Button(action: action) {
//            Image(uiImage: UIImage(data: webSites[index].siteFavIcon!) ?? UIImage(systemName: "globe")!)

            if let faviconData = webSites[index].siteFavIcon,
               let image = UIImage(data: faviconData) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: menuIconSize, height: menuIconSize)
                    .clipShape(Circle())
    /*
                    .overlay(
                        Circle()
                            .fill(hasInjectedScript ? Color.green : Color.clear)
                            .frame(width: 8, height: 8)
                        , alignment: .bottomLeading
                    )
    */
            } else {
                Image(systemName: "globe")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: menuIconSize, height: menuIconSize)
                    .clipShape(Circle())
    /*
                    .overlay(
                        Circle()
                            .fill(hasInjectedScript ? Color.green : Color.clear)
                            .frame(width: 8, height: 8)
                        , alignment: .bottomLeading
                    )
    */
            }
        }
    }
}
