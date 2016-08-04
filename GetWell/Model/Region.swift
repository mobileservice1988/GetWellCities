//
//  Region.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import RealmSwift

class Region: Object {
    
    dynamic var id        = ""
    dynamic var name      = ""
    dynamic var state     = ""
    dynamic var country   = ""
    dynamic var image     = ""
    dynamic var active    = false
    dynamic var lastSeen  = false
    dynamic var counter   = 0
    dynamic var online    = 0
    dynamic var events    = 0
    dynamic var places    = 0
    dynamic var distance  = 0.0
    dynamic var latitude  = 0.0
    dynamic var longitude = 0.0
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
