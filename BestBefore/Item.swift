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
    
    var picture: UIImage
    var expiresAt: Date
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("items")
    
    //MARK: Types
    
    struct PropertyKey {
        static let picture = "picture"
        static let expiresAt = "expiresAt"
    }
    
    public init(picture: UIImage, expiresAt: Date)
    {
        self.picture = picture
        self.expiresAt = expiresAt
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(self.picture, forKey: PropertyKey.picture)
        aCoder.encode(self.expiresAt, forKey: PropertyKey.expiresAt)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let expiresAt = aDecoder.decodeObject(forKey: PropertyKey.expiresAt) as? Date else {
            os_log("Unable to decode the expiresAt for a Item object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let picture = aDecoder.decodeObject(forKey: PropertyKey.picture) as? UIImage else {
            os_log("Unable to decode the picture for a Item object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        self.init(picture: picture, expiresAt: expiresAt)
    }
}

