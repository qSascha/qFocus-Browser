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
    private var identifier: String?
    
    private init() {
        publicDatabase = container.publicCloudDatabase
    }
    
    
    
    //MARK: Set Identifier
    func setIdentifier(_ identifier: String) {
        self.identifier = identifier
    }

    
    //MARK: Save
    func save(event: String, parameter: String) {
        let tempIdentifier = self.identifier

        queue.async { [self] in
            let record = CKRecord(recordType: recordType)
            record.setValue(applicationName, forKey: "Application")
            record.setValue(event, forKey: "Event")
            record.setValue(parameter, forKey: "Parameter")
            record.setValue(tempIdentifier, forKey: "Identifier")
            record.setValue(Date(), forKey: "EventDate")
            
            #if DEBUG
            print("Collector: Event: \(event) Parameter: \(parameter) Identifier: \(tempIdentifier ?? "no identifier")")
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
