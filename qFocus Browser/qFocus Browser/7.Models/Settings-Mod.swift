//
//  Settings.swift
//  qFocus Browser
//
//
import CoreData
import Foundation



@objc(SettingsStorage)
final class SettingsStorage: NSManagedObject, Identifiable {
    @NSManaged var id: UUID
    @NSManaged var enableAdBlock: Bool
    @NSManaged var freeFlowXPercent: Double
    @NSManaged var freeFlowYPercent: Double
    @NSManaged var adBlockLastUpdate: Date?
    @NSManaged var faceIDEnabled: Bool
    @NSManaged var onboardingComplete: Bool
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SettingsStorage> {
        return NSFetchRequest<SettingsStorage>(entityName: "SettingsStorage")
    }
    
}



