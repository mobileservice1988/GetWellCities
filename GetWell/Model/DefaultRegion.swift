//
//  DefaultRegion.swift
//  GetWell
//
//  Created by mac on 7/25/16.
//  Copyright © 2016 Beakyn Company. All rights reserved.
//

import RealmSwift

class DefaultRegion: Object {
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
    
    func initWithRegion(region : Region) {
        self.id = region.id
        self.name = region.name
        self.state = region.state
        self.country = region.country
        self.image = region.image
        self.active = region.active
        self.lastSeen = region.lastSeen
        self.counter = region.counter
        self.online = region.online
        self.events = region.events
        self.places = region.places
        self.distance = region.distance
        self.latitude = region.latitude
        self.longitude = region.longitude
    }
    func generateRegion() -> Region {
        let region = Region()
        region.id = self.id
        region.name = self.name
        region.state = self.state
        region.country = self.country
        region.image = self.image
        region.active = self.active
        region.lastSeen = self.lastSeen
        region.counter = self.counter
        region.online = self.online
        region.events = self.events
        region.places = self.places
        region.distance = self.distance
        region.latitude = self.latitude
        region.longitude = self.longitude
        return region
    }
}
