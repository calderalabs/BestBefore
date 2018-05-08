//
//  ItemPrototype.swift
//  BestBefore
//
//  Created by Matteo Depalo on 31/01/2018.
//  Copyright © 2018 Caldera Labs. All rights reserved.
//

import Foundation
import SwiftDate
import os.log

class ItemPrototype: NSObject, NSCoding
{
    override var hash: Int {
        return code.hashValue
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let rhs = object as? ItemPrototype else {
            return false
        }
        let lhs = self
        
        return lhs.code == rhs.code
    }
    //MARK: Properties
    
    var name: String
    var interval: TimeInterval
    var code: String
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("itemPrototypes")
    
    //MARK: Types
    
    struct PropertyKey {
        static let name = "name"
        static let interval = "interval"
        static let code = "code"
    }
    
    public init(name: String, interval: TimeInterval, code: String)
    {
        self.name = name
        self.interval = interval
        self.code = code
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder)
    {
        aCoder.encode(self.name, forKey: PropertyKey.name)
        aCoder.encode(self.interval, forKey: PropertyKey.interval)
        aCoder.encode(self.code, forKey: PropertyKey.code)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a ItemPrototype object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let code = aDecoder.decodeObject(forKey: PropertyKey.code) as? String else {
            os_log("Unable to decode the code for a ItemPrototype object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let interval = aDecoder.decodeDouble(forKey: PropertyKey.interval)
        
        if interval == 0.0 {
            os_log("Unable to decode the interval for a ItemPrototype object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        self.init(name: name, interval: interval, code: code)
    }
}

