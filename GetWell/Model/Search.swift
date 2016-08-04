//
//  Search.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import RealmSwift

class Search: Object {
    
    dynamic var term  = ""
    dynamic var count = 0
    dynamic var date  = 0.0
    
    override static func primaryKey() -> String? {
        return "term"
    }
}
