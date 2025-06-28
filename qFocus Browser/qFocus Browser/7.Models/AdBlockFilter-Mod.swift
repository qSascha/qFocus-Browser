//
//  AdBlockFilter.swift
//  qFocus Browser
//
//
import CoreData
import Foundation



//MARK: Ad-Block Filter Presentation
/// Presents mixed data from both: Default settings and the persistent store
final class AdBlockFilterDisplayItem: ObservableObject, Identifiable {
    var id: UUID = UUID()
    var sortOrder: Int = 0
    var filterID: String = ""
    var preSelectediOS: Bool = false
    var identName: String = ""
    var explanation: String = ""
    @Published var enabled: Bool = false
    var checksum: String = ""
    var languageCode: String = ""
}

/// Needed for .sheet showing the explanation.
extension AdBlockFilterDisplayItem: Equatable {
    static func == (lhs: AdBlockFilterDisplayItem, rhs: AdBlockFilterDisplayItem) -> Bool {
        lhs.id == rhs.id
    }
}




//MARK: Ad-Block Filter Setting
/// Storing the necessary information persitently.
@objc(AdBlockFilterSetting)
class AdBlockFilterSetting: NSManagedObject {
    
    @NSManaged var id: UUID
    @NSManaged var filterID: String
    @NSManaged var enabled: Bool
    @NSManaged var checksum: String
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<AdBlockFilterSetting> {
        return NSFetchRequest<AdBlockFilterSetting>(entityName: "AdBlockFilterSetting")
    }
    
}







//MARK: Ad Block Filter Array
/// Default settings
struct AdBlockFilterItem: Identifiable {
    let id: String
    let sortOrder: Int
    let filterID: String
    var preSelectediOS: Bool
    let preSelectedmacOS: Bool
    let urlString: String
    let languageCode: String
    let identName: String
    let explanation: String
    
    init(sortOrder: Int, filterID: String, preSelectediOS: Bool, preSelectedmacOS: Bool, urlString: String, languageCode: String, identName: String, explanation: String) {
        self.id = filterID
        self.sortOrder = sortOrder
        self.filterID = filterID
        self.preSelectediOS = preSelectediOS
        self.preSelectedmacOS = preSelectedmacOS
        self.urlString = urlString
        self.languageCode = languageCode
        self.identName = identName
        self.explanation = explanation
    }
    
}



/*
//MARK: Error Types
enum BlockListError: Error {
    case invalidData
    case invalidResponse
    case compilationFailed
    case storeUnavailable
}
*/
