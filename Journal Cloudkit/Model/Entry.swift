//
//  Entry.swift
//  Journal Cloudkit
//
//  Created by Greg Hughes on 12/31/18.
//  Copyright © 2018 Greg Hughes. All rights reserved.
//

import Foundation
import CloudKit


struct Constants{
    
    static let RecordKey = "Entry"
    static let TitleKey = "title"
    static let BodyKey = "body"
    
}

class Entry {
    
    
    var title : String
    var body : String
    let ckRecordID: CKRecord.ID
    
    
    init(title: String, body: String, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString) ) {
        
        self.title = title
        self.body = body
        self.ckRecordID = ckRecordID
        
    }
    
    
    
    convenience init?(ckRecord: CKRecord){
        
        guard let title = ckRecord[Constants.TitleKey] as? String,
            let body = ckRecord[Constants.BodyKey] as? String  else { return nil}
        //why do we guard let it here
        
        self.init(title: title, body: body, ckRecordID: ckRecord.recordID)
        
        //what does this do?
        
    }
    
    var cloudKitRecord: CKRecord {
        
        let record = CKRecord(recordType: Constants.RecordKey)
        record.setValue(title, forKey: Constants.TitleKey)
        record.setValue(body, forKey: Constants.BodyKey)
        
        return record
    }
}


extension Entry: Equatable{
    
    static func ==(lhs: Entry, rhs: Entry) -> Bool{
        return lhs.title == rhs.title && lhs.body == rhs.body 
    }
}


extension CKRecord{
    
    convenience init(entry: Entry){
        
        self.init(recordType: Constants.RecordKey, recordID: entry.ckRecordID)
        
        self.setValue(entry.title, forKey: Constants.TitleKey)
        self.setValue(entry.body, forKey: Constants.BodyKey)
        
    }
}
