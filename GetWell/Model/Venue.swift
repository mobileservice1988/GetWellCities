//
//  Venue.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import CoreLocation
import RealmSwift

class Venue: Object {
    
    dynamic var id                = ""
    dynamic var slug              = ""
    dynamic var info              = ""
    dynamic var type              = ""
    dynamic var kind              = ""
    dynamic var name              = ""
    dynamic var poster            = ""
    dynamic var media             = ""
    dynamic var email             = ""
    dynamic var phone             = ""
    dynamic var links             = ""
    dynamic var website           = ""
    dynamic var category          = ""
    dynamic var subcategory       = ""
    dynamic var regionID          = ""
    dynamic var regionName        = ""
    dynamic var address1          = ""
    dynamic var address2          = ""
    dynamic var zip               = ""
    dynamic var city              = ""
    dynamic var state             = ""
    dynamic var crossStreet       = ""
    dynamic var neighborhood      = ""
    dynamic var updatedAt         = ""
    dynamic var cuisines          = ""
    dynamic var nutrition         = ""
    dynamic var goodFor           = ""
    dynamic var menus             = ""
    dynamic var alcohol           = ""
    dynamic var attire            = ""
    dynamic var workouts          = ""
    dynamic var amenities         = ""
    dynamic var outdoorRecreation = ""
    dynamic var healingServices   = ""
    dynamic var products          = ""
    dynamic var peopleServed      = ""
    dynamic var payment           = ""
    dynamic var parking           = ""
    dynamic var transit           = ""
    dynamic var openingHours      = ""
    dynamic var eventType         = ""
    dynamic var eventDates        = ""
    dynamic var eventLocation     = ""
    dynamic var eventOrganizer    = ""
    dynamic var onlineContent     = ""
    dynamic var featured          = false
    dynamic var certified         = false
    dynamic var favorite          = false
    dynamic var openNow           = false
    dynamic var cost              = 0
    dynamic var rate              = 0.0
    dynamic var sort              = 0.0
    dynamic var score             = 0.0
    dynamic var latitude          = 0.0
    dynamic var longitude         = 0.0
    dynamic var reviews           = "";

    override static func primaryKey() -> String? {
        return "id"
    }
}

func ==(lhs: Venue, rhs: Venue) -> Bool {
    return lhs.isEqual(rhs)
}
