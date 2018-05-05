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
    var picture: UIImage?
    var expiresAt: Date
    var code: String?
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("items")
    
    //MARK: Types
    
    struct PropertyKey {
        static let name = "name"
        static let picture = "picture"
        static let expiresAt = "expiresAt"
        static let code = "code"
    }
    
    public init(name: String, picture: UIImage?, expiresAt: Date, code: String?)
    {
        self.name = name
        self.picture = picture
        self.expiresAt = expiresAt
        self.code = code
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(self.name, forKey: PropertyKey.name)
        aCoder.encode(self.picture, forKey: PropertyKey.picture)
        aCoder.encode(self.expiresAt, forKey: PropertyKey.expiresAt)
        aCoder.encode(self.code, forKey: PropertyKey.code)
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
        
        guard let picture = aDecoder.decodeObject(forKey: PropertyKey.picture) as? UIImage else {
            os_log("Unable to decode the picture for a Item object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let code = aDecoder.decodeObject(forKey: PropertyKey.code) as? String else {
            os_log("Unable to decode the code for a Item object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        self.init(name: name, picture: picture, expiresAt: expiresAt, code: code)
    }
}

