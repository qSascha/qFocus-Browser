//
//  Sites.swift
//  qFocus Browser
//
//
import CoreData
import Foundation



//MARK: Site Details - Web Views
struct SitesDetails: Identifiable {
    let id: UUID
    let viewModel: WebViewVM
}


//MARK: Site Details - Navigation Buttons
struct SitesNavButton: Identifiable {
    let id: UUID
    let siteName: String
    let siteFavIcon: Data?
}




//MARK: Core Data
@objc(SitesStorage)
class SitesStorage: NSManagedObject {
    @NSManaged var cookieStoreID: UUID
    @NSManaged var siteOrder: Int
    @NSManaged var siteName: String
    @NSManaged var siteURL: String
    @NSManaged var siteFavIcon: Data?
    @NSManaged var enableGreasy: Bool
    @NSManaged var enableAdBlocker: Bool
    @NSManaged var requestDesktop: Bool

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SitesStorage> {
        return NSFetchRequest<SitesStorage>(entityName: "SitesStorage")
    }
}
