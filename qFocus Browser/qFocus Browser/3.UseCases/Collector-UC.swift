//
//  Collector-UC.swift
//  qFocus Browser
//
//
import CloudKit



@MainActor
final class CollectorUC {
    
    private let container = CKContainer(identifier: "iCloud.qSascha.collector")
    private let publicDatabase: CKDatabase
    private let recordType = "Events"
    private let applicationName = "qFocus Browser"
    
    init() {
        self.publicDatabase = container.publicCloudDatabase
    }
    
    func save(event: String, parameter: String) {
        let record = CKRecord(recordType: recordType)
        record["Application"] = applicationName
        record["Event"] = event
        record["Parameter"] = parameter
        record["EventDate"] = Date()
        
        publicDatabase.save(record) { savedRecord, error in
            if let error = error {
                print("Error: Failed to save record to CloudKit: \(error)")
            }
        }
    }
}






/*
import SwiftData






 @MainActor
 final class CollectorUC {

     static let shared = CollectorUC()
     
     private let container = CKContainer(identifier: "iCloud.qSascha.collector")
     private let publicDatabase: CKDatabase
     private let recordType = "Events"
     private let applicationName = "qFocus Browser"

     init() {
         publicDatabase = container.publicCloudDatabase
     }

     func save(event: String, parameter: String) {
         let record = CKRecord(recordType: recordType)
         record.setValue(applicationName, forKey: "Application")
         record.setValue(event, forKey: "Event")
         record.setValue(parameter, forKey: "Parameter")
         record.setValue(Date(), forKey: "EventDate")
         
         publicDatabase.save(record) { savedRecord, error in
             if let error = error {
                 print("Error: Failure to save record to Cloud Kit: \(error)")
             }
         }
     }

 }


 */
