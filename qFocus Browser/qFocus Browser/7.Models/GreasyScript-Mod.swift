//
//  GreasyScript-Mod.swift
//  qFocus Browser
//
//
import CoreData
import Foundation




//MARK: GreasyFork Script Setting
@objc(GreasyScriptStorage)
public class GreasyScriptStorage: NSManagedObject {
    
    @NSManaged public var id: UUID
    @NSManaged public var scriptID: String
    @NSManaged public var scriptEnabled: Bool

    @NSManaged public var scriptName: String
    @NSManaged public var coreSite: String
    @NSManaged public var scriptExplanation: String
    @NSManaged public var scriptLicense: String
    @NSManaged public var siteURL: String
    @NSManaged public var scriptURL: String
    @NSManaged public var defaultScript: Bool

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GreasyScriptStorage> {
        return NSFetchRequest<GreasyScriptStorage>(entityName: "GreasyScriptStorage")
    }
    
}





//MARK: Greasy Scripts List
struct defaultGreasyScriptItem: Hashable {
    var id: UUID = UUID()
    var scriptName: String
    var scriptID: String
    var coreSite: String
    var scriptEnabled: Bool
    var scriptExplanation: String
    var scriptLicense: String
    var siteURL: String
    var scriptURL: String
    var defaultScript: Bool
}

