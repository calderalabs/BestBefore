//
//  Item.swift
//  BestBefore
//
//  Created by Matteo Depalo on 31/01/2018.
//  Copyright © 2018 Caldera Labs. All rights reserved.
//

import Foundation
import SwiftDate
import os.log

class Item: NSObject, NSCoding
{
    //MARK: Properties
    
    var name: String
    var expiresAt: Date
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("items")
    
    //MARK: Types
    
    struct PropertyKey {
        static let name = "name"
        static let expiresAt = "expiresAt"
    }
    
    public init(name: String, expiresAt: Date)
    {
        self.name = name
        self.expiresAt = expiresAt
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(self.name, forKey: PropertyKey.name)
        aCoder.encode(self.expiresAt, forKey: PropertyKey.expiresAt)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Item object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let expiresAt = aDecoder.decodeObject(forKey: PropertyKey.expiresAt) as? Date else {
            os_log("Unable to decode the expiresAt for a Item object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        self.init(name: name, expiresAt: expiresAt)
    }
}

