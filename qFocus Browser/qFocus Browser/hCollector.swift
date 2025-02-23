//
//  hCollector.swift
//  qFocus Browser
//
//  Created by Sascha on 2025-02-22.
//

import CloudKit
import CoreData
import SwiftData







//MARK: CloudKit Collector
@Model
class collectorModel {
    var id: UUID = UUID()
    var Application: String = "qFocus Browser"
    var Event: String = ""
    var EventDate: Date = Date()
    var Parameter: String = ""
    
    init(id: UUID, Application: String, Event: String, EventDate: Date, Parameter: String) {
        self.id = id
        self.Application = Application
        self.Event = Event
        self.EventDate = EventDate
        self.Parameter = Parameter
    }
}





class Collector: ObservableObject {
    static let shared = Collector()
    
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








