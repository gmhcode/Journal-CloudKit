//
//  EntryController.swift
//  Journal Cloudkit
//
//  Created by Greg Hughes on 12/31/18.
//  Copyright © 2018 Greg Hughes. All rights reserved.
//

import Foundation
import CloudKit

class EntryController {
    
    var entries : [Entry] = []
    static let shared = EntryController()
    
    let privateDB = CKContainer.default().privateCloudDatabase
    
    //crud
    
    func saveEntryToCloudKit(entry: Entry, completion: @escaping (Bool) -> ()){
        
        let entryRecord = entry.cloudKitRecord
        
        CKContainer.default().privateCloudDatabase.save(entryRecord) { (record, error) in
            
            if let error = error {
                print("❌ There was an error in \(#function) \(error) : \(error.localizedDescription)")
                completion(false)
                return
            }
            
            
            guard let record = record, let entry = Entry(ckRecord: record) else {completion(false) ; return}
            
            self.entries.append(entry)
            
            completion(true)
        }
    }
    
    
    
    func updateEntry(entry: Entry, title: String, body: String, completion: @escaping (Bool) -> Void){
        
        //Update the local entry
        entry.title = title
        entry.body = body
        
        //Update the entry's remote record from cloudKit
        privateDB.fetch(withRecordID: entry.ckRecordID) { (record, error) in
            if let error = error{
                print("\(error.localizedDescription) \(error) in function: \(#function)")
                completion(false)
                return
            }
            
            guard let record = record else {completion(false) ; return}
            
            record[Constants.TitleKey] = title
            record[Constants.BodyKey] = body
            
            let operation = CKModifyRecordsOperation(recordsToSave: [record], recordIDsToDelete: nil)
            operation.savePolicy = .changedKeys
            operation.queuePriority = .high
            operation.qualityOfService = .userInitiated
            operation.modifyRecordsCompletionBlock = { (records, reordIDs, error) in
                completion(true)
            }
            self.privateDB.add(operation)
        }
        }
    
    func deleteEntry(entry: Entry, completion: @escaping (Bool) -> ()){
        
        //Delete the entry locally
        guard let index = EntryController.shared.entries.index(of: entry) else {return}
        EntryController.shared.entries.remove(at: index)
        
        //Delete the entry from CloudKit
        privateDB.delete(withRecordID: entry.ckRecordID) { (_, error) in
            if let error = error{
                print("\(error.localizedDescription) \(error) in function: \(#function)")
                completion(false)
                return
            }else {
                print("Record Deleted from CloudKit")
                completion(true)
            }
        }
    }
    
    
    
    func addEntryWith(title: String, body: String, completion: @escaping (Bool) -> ()){
        
        
        let addedEntry = Entry(title: title, body: body)
        
        saveEntryToCloudKit(entry: addedEntry) { (success) in
            
          success ? completion(true) : completion(false)
            
        }
    }
    
    
    
    func fetchEntries(completion: @escaping (Bool) -> ()){
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Constants.RecordKey, predicate: predicate)
        
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            
            if let error = error {
                print("❌ There was an error in \(#function) \(error) : \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let records = records else {completion(false) ; return}
            
            let entries = records.compactMap{ Entry(ckRecord: $0)}
            self.entries = entries
            
            completion(true)
        }
    }
}
