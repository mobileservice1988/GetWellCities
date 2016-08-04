//
//  APIManager.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import Foundation
import CoreLocation
import RealmSwift

class APIManager: ParseOperationDelegate, NetworkOperationDelegate  {
    
    static let sharedManager = APIManager()
    
    let sharedUI = UIManager.sharedManager
    let sharedLocation = LocationManager.sharedManager
    var notifiedQueries = false
    
    lazy var downloadInProgress = [String : NSOperation]()
    lazy var downloadQueue: NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Download Queue"
        queue.maxConcurrentOperationCount = 8
        queue.qualityOfService = .Background
        return queue
    }()
    
    lazy var parseInProgress = [String : NSOperation]()
    lazy var parseQueue: NSOperationQueue = {
        var queue = NSOperationQueue()
        queue.name = "Parse Queue"
        queue.maxConcurrentOperationCount = 8
        queue.qualityOfService = .UserInteractive
        return queue
    }()
    
    let appCategories = "&category=eat,move,heal"
    let distance     = "&distance=12500mi"
    let pageFields   = "&fields=name,score,poster,kind,category,website,description,certified,featured,phone,rating,cost,region,neighborhoods,addr1,zip,subcategory,state,city,geometry.coordinates"
    let detailFields = "?fields=media,slug,email,city,type,links,website,updatedAt,addr2,crossStreet,parking,transit,paymentOptions,openingHours,reviews"
    
    let eatClassifications    = ",cuisine,nutrition,goodFor,alcohol,attire,menus,menu,reservations"
    let moveClassifications   = ",workouts,amenities,outdoorRecreation,healingServices,products"
    let healClassifications   = ",healingServices,products,peopleServed"
    let eventClassifications  = ",eventOrganizer,eventLocation,eventType,dates"
    let onlineClassifications = ",content"
    
    var queries = [String]()
    
    
    func getDataForMapArea(coordinates: CLLocationCoordinate2D, radius: Double, filters:[String], completionHandler:(venues: [Venue]?) -> ()) {
        
        let lat = String(coordinates.latitude)
        let lng = String(coordinates.longitude)
        let distance = "&distance=\(radius)mi"
        
        var categories = "&category="
        var costSection = ""
        var ratingSection = ""
        
        for (index, filter) in filters.enumerate() {
            if index == 0 {
                categories = categories + filter
            }
            else {
                let arry = filter.componentsSeparatedByString(":")
                if arry[0] == "cost" {
                    costSection = filter
                } else if arry[0] == "rating" {
                    ratingSection = filter
                } else {
                    categories = categories + ",\(filter)"
                }
            }
        }
        var URL = ""
        if categories != "&category=" {
            
            if costSection.characters.count > 0 || ratingSection.characters.count > 0 {
                URL = Constants.GWAPI.queryURL + "status:published " + "+" + ratingSection + "+" + costSection + "&lat=\(lat)" + "&lng=\(lng)" + "&kind=place" + "&size=50" + distance + categories + pageFields
            } else {
                URL = Constants.GWAPI.queryURL + "status:published " + "&lat=\(lat)" + "&lng=\(lng)" + "&kind=place" + "&size=\(sharedUI.pageSize)" + distance + categories + pageFields
            }
            
        }
        else {
            URL = Constants.GWAPI.queryURL + "status:published " + "&lat=\(lat)" + "&lng=\(lng)" + "&kind=place" + "&size=50" + distance + pageFields
        }
        URL = URL.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!

        var object: AnyObject? {
            didSet {
                let parseOP = ParseVenueListOperation(object: object!, delegate: self, URL: URL, completionHandler: { (values) in
                    var venues: [Venue] = []
                    for value in values {
                        let venue = Venue(value: value)
                        venues.append(venue)
                    }
                    venues.sortInPlace({ $0.sort < $1.sort })
                    completionHandler(venues: venues)
                })
                parseInProgress[URL] = parseOP
                parseQueue.addOperation(parseOP)
            }
        }
        
        if downloadInProgress[URL] == nil && parseInProgress[URL] == nil {
            let networkOP = NetworkOperation(URL: URL, delegate: self) { (responseObject, error) in
                if responseObject != nil {
                    object = responseObject
                }
            }
            downloadInProgress[URL] = networkOP
            downloadQueue.addOperation(networkOP)
        }
    }
    
    func getDataForPage(page: Int, regionID: String, filters:[String], completionHandler:(venues: [Venue]?) ->()) {
        
        var categories = "&category="
        var costSection = ""
        var ratingSection = ""
        for (index, filter) in filters.enumerate() {
            if index == 0 {
                categories = categories + filter
            }
            else {
                let arry = filter.componentsSeparatedByString(":")
                if arry[0] == "cost" {
                    costSection = filter
                } else if arry[0] == "rating" {
                    ratingSection = filter
                } else {
                    categories = categories + ",\(filter)"
                }
                
            }
        }
        
        let from = page * sharedUI.pageSize
        var URL : String = "";
        if costSection.characters.count > 0 || ratingSection.characters.count > 0 {
            URL = Constants.GWAPI.queryURL +
                "status:published" + "+" +
                "region._id:\(regionID)" + "+" +
                ratingSection + "+" +
                costSection +
                "&kind=place" +
                "&from=\(from)" +
                "&size=\(sharedUI.pageSize)" +
            pageFields
        } else {
            URL = Constants.GWAPI.queryURL +
                "status:published" + "+" +
                "region._id:\(regionID)" +
                
                "&kind=place" +
                "&from=\(from)" +
                "&size=\(sharedUI.pageSize)" +
            pageFields
        }
        
        
        if sharedLocation.status == .AuthorizedWhenInUse {
            let lat  = String(sharedLocation.currentLocation.coordinate.latitude)
            let lng  = String(sharedLocation.currentLocation.coordinate.longitude)
            let latitude = "&lat=\(lat)"
            let longitude = "&lng=\(lng)"
            URL = URL + latitude + longitude + distance
        }
        
        if categories != "&category=" {
            URL = URL + categories
        }
        
        var object: AnyObject? {
            didSet {
                let parseOP = ParseVenueListOperation(object: object!, delegate: self, URL: URL, completionHandler: { (values) in
                    var venues: [Venue] = []
                    for value in values {
                        let venue = Venue(value: value)
                        venues.append(venue)
                    }
                    if self.sharedLocation.status == .AuthorizedWhenInUse {
                        venues.sortInPlace({ $0.sort < $1.sort })
                    }
                    else {
                        venues.sortInPlace({ $0.name < $1.name })
                    }
                    completionHandler(venues: venues)
                })
                parseInProgress[URL] = parseOP
                parseQueue.addOperation(parseOP)
            }
        }
        
        if downloadInProgress[URL] == nil && parseInProgress[URL] == nil {
            let networkOP = NetworkOperation(URL: URL, delegate: self) { (responseObject, error) in
                if responseObject != nil {
                    object = responseObject
                }
            }
            downloadInProgress[URL] = networkOP
            downloadQueue.addOperation(networkOP)
        }
    }
        
    func getDataForVenue(venueID: String, completionHandler:(value: [String: AnyObject]!) -> ()) {
        
        let URL = Constants.GWAPI.baseURL + "venues/" + venueID        
        var object: AnyObject? {
            didSet {
                let parseOP = ParseVenueOperation(object: object!, delegate: self, URL: URL, completionHandler: { (value) in
                    if value != nil {
                        completionHandler(value: value)
                    }
                })
                parseInProgress[URL] = parseOP
                parseQueue.addOperation(parseOP)
            }
        }
        if downloadInProgress[URL] == nil && parseInProgress[URL] == nil {
            let networkOP = NetworkOperation(URL: URL, delegate: self) { (responseObject, error) in
                if responseObject != nil {
                    object = responseObject
                }
            }
            downloadInProgress[URL] = networkOP
            downloadQueue.addOperation(networkOP)
        }
    }
    
    func getVenueDetail(venue: Venue) {
        
        let venueID = venue.id
        let category = venue.category.lowercaseString
        var URL = Constants.GWAPI.baseURL + "venues/\(venueID)" + detailFields
        if category == "eat"    { URL = URL + eatClassifications }
        if category == "move"   { URL = URL + moveClassifications }
        if category == "heal"   { URL = URL + healClassifications }
        if category == "online" { URL = URL + onlineClassifications }
        if category == "event"  { URL = URL + eventClassifications }
        
        var object: AnyObject? {
            didSet {
                let parseOP = ParseVenueDetailOperation(object: object!, delegate: self, URL: URL, completionHandler: { (value) in
                    if value != nil {
                        self.parseVenueOperationFinished(value)
                    }
                })
                parseInProgress[URL] = parseOP
                parseQueue.addOperation(parseOP)
            }
        }
        
        if downloadInProgress[URL] == nil && parseInProgress[URL] == nil {
            let networkOP = NetworkOperation(URL: URL, delegate: self) { (responseObject, error) in
                if responseObject != nil {
                    object = responseObject
                }
            }
            downloadInProgress[URL] = networkOP
            downloadQueue.addOperation(networkOP)
        }
    }
    
    func parseVenueOperationFinished(value: [String: AnyObject]?) {
        let realm = try! Realm()
        if value != nil {
            try! realm.write {
                realm.create(Venue.self, value: value!, update: true)
            }
        }
    }
    
    func venuesParseFinished(values: [[String: AnyObject]]?) {
        let realm = try! Realm()
        if values != nil {
            try! realm.write {
                for value in values! {
                    realm.create(Venue.self, value: value, update: true)
                }
            }
        }
    }
    
    func performQueries() {
        let queries = try! Realm().objects(Query)
        for query in queries {
            var term = ""
            let queryID = query.id
            if query.value.containsString("[city]") { term = query.value.stringByReplacingOccurrencesOfString("[city]", withString: "new york") }
            else { term = query.value }
            
            let URL = Constants.GWAPI.queryURL + term.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! + pageFields + "&size=25"
            self.queries.append(URL)
            var object: AnyObject? {
                didSet {
                    let parseOP = ParseVenueListOperation(object: object!, delegate: self, URL: URL, completionHandler: { (values) in
                        let realm = try! Realm()
                        let query = realm.objects(Query).filter("id == '\(queryID)'").first!
                        var references = ""
                        realm.beginWrite()
                        for value in values {
                            let venueID = value["id"]!
                            references = references + ",\(venueID)"
                            realm.create(Venue.self, value: value, update: true)
                        }
                        if references != "" { references = references.substringFromIndex(references.startIndex.advancedBy(1)) }
                        query.references = references
                        try! realm.commitWrite()
                    })
                    parseInProgress[URL] = parseOP
                    parseQueue.addOperation(parseOP)
                }
            }
            
            let networkOP = NetworkOperation(URL: URL, delegate: self, networkOperationCompletionHandler: { (responseObject, error) in
                if responseObject != nil {
                    object = responseObject
                }
            })
            downloadInProgress[URL] = networkOP
            downloadQueue.addOperation(networkOP)
        }
    }
    
    func importQueries() {
        
        let URL = Constants.GWAPI.baseURL + "queries"
        var object: AnyObject? {
            didSet {
                let parseOP = ParseQueryOperation(object: object!, delegate: self)
                parseInProgress[URL] = parseOP
                parseQueue.addOperation(parseOP)
            }
        }
        
        let importOP = NetworkOperation(URL: URL, delegate: self) { (responseObject, error) -> () in
            if responseObject != nil {
                object = responseObject
            }
        }
        downloadInProgress[URL] = importOP
        downloadQueue.addOperation(importOP)
    }
    
    func importRegions() {
        
        let URL = Constants.GWAPI.baseURL + "regions?active=true"
       
        var object: AnyObject? {
            didSet {
                let parseOP = ParseRegionOperation(object: object!, URL: URL, delegate: self)
                parseInProgress[URL] = parseOP
                parseQueue.addOperation(parseOP)
            }
        }
        
        let importOP = NetworkOperation(URL: URL,  delegate: self) { (responseObject, error) -> () in
            if responseObject != nil {
                object = responseObject
            }
        }
        downloadInProgress[URL] = importOP
        downloadQueue.addOperation(importOP)
    }
    
    func retrieveFeaturedVenues() {
        
        let URL = Constants.GWAPI.queryURL + "status:published" + "+featured:true" + "&kind=place" + "&category=eat,heal,move"
        var object: AnyObject? {
            didSet {
                let parseOP = ParseVenueListOperation(object: object!, delegate: self, URL: URL, completionHandler: { (values) in
                    let realm = try! Realm()
                    realm.beginWrite()
                    realm.objects(Venue).setValue(false, forKey: "featured")
                    try! realm.commitWrite()
                    self.venuesParseFinished(values)
                    
                })
                parseInProgress[URL] = parseOP
                parseQueue.addOperation(parseOP)
            }
        }
        
        let importOP = NetworkOperation(URL: URL, delegate: self) { (responseObject, error) -> () in
            if responseObject != nil {
                object = responseObject
            }
        }
        downloadInProgress[URL] = importOP
        downloadQueue.addOperation(importOP)
    }
    
    func searchForTerms(terms: String, completionHandler:(venues: [Venue]?) -> ()) {
        
        let query  = "&q=" + terms.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())! + "+"
        var URL = Constants.GWAPI.baseURL + "venues?"

        if sharedLocation.status == .AuthorizedWhenInUse {
            let lat = String(sharedLocation.currentLocation.coordinate.latitude)
            let lng = String(sharedLocation.currentLocation.coordinate.longitude)
            let latitude = "lat=\(lat)"
            let longitude = "&lng=\(lng)"
            URL = URL + latitude + longitude + distance
        }
        
        URL = URL + query + "status:published" + "&size=100" + pageFields
        
        var object: AnyObject? {
            didSet {
                let parseOP = ParseVenueListOperation(object: object!, delegate: self, URL: URL, completionHandler: { (values) in
                    var venues: [Venue] = []
                    for value in values {
                        let venue = Venue(value: value)
                        venues.append(venue)
                    }
                    completionHandler(venues: venues)
                })
                parseInProgress[URL] = parseOP
                parseQueue.addOperation(parseOP)
            }
        }
        
        if downloadInProgress[URL] == nil && parseInProgress[URL] == nil {
            let searchOP = NetworkOperation(URL: URL, delegate: self) { (responseObject, error) in
                if responseObject != nil {
                    object = responseObject
                }
            }
            downloadInProgress[URL] = searchOP
            downloadQueue.addOperation(searchOP)
        }
    }
    
    func networkOperationFinished(operation: NetworkOperation) {
        downloadInProgress.removeValueForKey(operation.URL)
    }
    
    func parseVenueOperationFinished(operation: ParseVenueOperation) {
        parseInProgress.removeValueForKey(operation.URL)
    }
    
    func parseVenueDetailOperationFinished(operation: ParseVenueDetailOperation) {
        parseInProgress.removeValueForKey(operation.URL)
    }
    
    func parseQueryOperationFinished(operation: ParseQueryOperation) {
        performQueries()
    }
    
    func parseRegionOperationFinished(operation: ParseRegionOperation) {
        parseInProgress.removeValueForKey(operation.URL)
        dispatch_async(dispatch_get_main_queue(),{
            NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notification.Region, object: nil)
        })
    }
    
    func parseVenueListOperationFinished(operation: ParseVenueListOperation) {
        parseInProgress.removeValueForKey(operation.URL)
        if operation.URL! == queries.last {
            dispatch_async(dispatch_get_main_queue(),{
                NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notification.Slider, object: nil)
            })
        }
    }

}

