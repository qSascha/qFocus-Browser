//
//  Settings-Repo.swift
//  qFocus Browser
//
//
import Foundation
import CoreData



final class SettingsRepo: ObservableObject {
    private let context: NSManagedObjectContext

    
    
    //MARK: Init
    init(context: NSManagedObjectContext) {
        self.context = context
    }

    

    //MARK: Get
    func get() -> SettingsStorage {
        let request: NSFetchRequest<SettingsStorage> = SettingsStorage.fetchRequest()
        if let existing = try? context.fetch(request).first {
            return existing
        }

        let newSettings = SettingsStorage(context: context)
        newSettings.id = UUID()
        try? context.save()
        return newSettings
    }


    
    //MARK: Update
    func update(_ block: (inout SettingsStorage) -> Void) {
        var settings = get()
            block(&settings)
        try? context.save()
    }

    
    
    //MARK: Save
    func save() {
        try? context.save()
    }
    

}
