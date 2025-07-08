//
//  Sites.swift
//  qFocus Browser
//
//
import CoreData
import Foundation



class SitesRepo: ObservableObject {
    let context: NSManagedObjectContext

    
    
    //MARK: Init
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    
    
    //MARK: addSite
    func addSite(siteOrder: Int = 0, siteName: String = "", siteURL: String = "", siteFavIcon: Data? = nil, enableGreasy: Bool = true, enableAdBlocker: Bool = true, requestDesktop: Bool = false, cookieStoreID: UUID? = nil) {
        let site = SitesStorage(context: context)
        site.cookieStoreID = UUID()
        site.siteOrder = siteOrder
        site.siteName = siteName
        site.siteURL = siteURL
        site.siteFavIcon = siteFavIcon
        site.enableGreasy = enableGreasy
        site.enableAdBlocker = enableAdBlocker
        site.requestDesktop = requestDesktop
        do {
            try context.save()
#if DEBUG
            print("🧩 Saving with context: \(ObjectIdentifier(context))")
            print("✅ Site successfully added: \(siteName)")
#endif
        } catch {
#if DEBUG
            print("🧩 Saving with context: \(ObjectIdentifier(context))")
            print("❌ Failed to save site: \(siteName), error: \(error.localizedDescription)")
#endif
        }    
    }
    
    
    
    //MARK: editSite
    func editSite(site: SitesStorage, siteOrder: Int, siteName: String, siteURL: String, siteFavIcon: Data?, enableGreasy: Bool, enableAdBlocker: Bool, requestDesktop: Bool, cookieStoreID: UUID?) {
        site.siteOrder = siteOrder
        site.siteName = siteName
        site.siteURL = siteURL
        site.siteFavIcon = siteFavIcon
        site.enableGreasy = enableGreasy
        site.enableAdBlocker = enableAdBlocker
        site.requestDesktop = requestDesktop
        site.cookieStoreID = cookieStoreID ?? UUID()
        do {
            try context.save()
#if DEBUG
            print("🧩 Saving with context: \(ObjectIdentifier(context))")
            print("✅ Site successfully updated: \(siteName)")
#endif
        } catch {
#if DEBUG
            print("🧩 Saving with context: \(ObjectIdentifier(context))")
            print("❌ Failed to save site: \(siteName), error: \(error.localizedDescription)")
#endif
        }    
    }
    
    
    
    
    //MARK: deleteSite
    func deleteSite(_ site: SitesStorage) {
        context.delete(site)
        do {
            try context.save()
#if DEBUG
            print("✅ Site successfully deleted.")
#endif
        } catch {
#if DEBUG
            print("❌ Failed to delete site.")
#endif
        }    
    }
    
    
    
    // MARK: getAllSites
    func getAllSites(order: SortOrder = .ascending) -> [SitesStorage] {
        let request: NSFetchRequest<SitesStorage> = SitesStorage.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \SitesStorage.siteOrder, ascending: order == .ascending)]
        let sites = (try? context.fetch(request)) ?? []
        return sites
    }
    
    
    
    //MARK: deleteAllSites
    func deleteAllSites() {
        let sites = getAllSites()
        for site in sites {
            context.delete(site)
        }
        do {
            try context.save()
#if DEBUG
            print("✅ All sites successfully deleted.")
#endif
        } catch {
#if DEBUG
            print("❌ Failed to delete all sites.")
#endif
        }    
    }
    


    //MARK: Reorder Sites
    func reorderSites() {
        do {
            let request: NSFetchRequest<SitesStorage> = SitesStorage.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \SitesStorage.siteOrder, ascending: true)]
            let sites = try context.fetch(request)
            for (index, site) in sites.enumerated() {
                site.siteOrder = index
            }
            try context.save()
#if DEBUG
            print("✅ Sites successfully reordered.")
#endif
        } catch {
#if DEBUG
            print("❌ Failed to reorder sites: \(error.localizedDescription)")
#endif
        }
    }

    
    
    //MARK: Persist Site Order
    func persistSiteOrder(sites: [SitesStorage]) {
        for (index, site) in sites.enumerated() {
            site.siteOrder = index
        }
        try? context.save()
    }
 
    
    
}
