//
//  Query.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import RealmSwift

class Query: Object {
    
    dynamic var id           = ""
    dynamic var name         = ""
    dynamic var value        = ""
    dynamic var updatedAt    = ""
    dynamic var createdAt    = ""
    dynamic var category     = ""
    dynamic var categoryID   = ""
    dynamic var references   = ""
    dynamic var counter      = 0
    dynamic var lastSeen     = false

    override static func primaryKey() -> String? {
        return "id"
    }
}

func ==(lhs: Query, rhs: Query) -> Bool {
    return lhs.isEqual(rhs)
}