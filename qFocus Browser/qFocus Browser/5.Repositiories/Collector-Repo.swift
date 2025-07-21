//
//  Collector-Repo.swift
//  qFocus Browser
//
//
import CloudKit
import CoreData


@MainActor
final class Collector: ObservableObject {
    static let shared = Collector()
    
    private let queue = DispatchQueue(label: "CollectorQueue")

    private let container = CKContainer(identifier: "iCloud.qSascha.collector")
    private let publicDatabase: CKDatabase
    private let recordType = "Events"
    private let applicationName = "qFocus Browser"
    
    private init() {
        publicDatabase = container.publicCloudDatabase
    }
    


    func save(event: String, parameter: String) {
        queue.async { [self] in
            let record = CKRecord(recordType: recordType)
            record.setValue(applicationName, forKey: "Application")
            record.setValue(event, forKey: "Event")
            record.setValue(parameter, forKey: "Parameter")
            record.setValue(Date(), forKey: "EventDate")
            
            #if DEBUG
            print("Collector: Event: \(event) Parameter: \(parameter)")
            #endif
            publicDatabase.save(record) { savedRecord, error in
                if let error = error {
#if DEBUG
                    print("Error: Failure to save record to Cloud Kit: \(error)")
#endif
                }
            }
        }
    }

    
}
