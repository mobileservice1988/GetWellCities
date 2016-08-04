//
//  APIOperations.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import Alamofire
import RealmSwift
import SwiftyJSON

protocol ParseOperationDelegate {
    func parseQueryOperationFinished(operation:  ParseQueryOperation)
    func parseRegionOperationFinished(operation: ParseRegionOperation)
    func parseVenueOperationFinished(operation:  ParseVenueOperation)
    func parseVenueDetailOperationFinished(operation:  ParseVenueDetailOperation)
    func parseVenueListOperationFinished(operation: ParseVenueListOperation)
}

protocol NetworkOperationDelegate {
    func networkOperationFinished(operation: NetworkOperation)
}

class APIOperations {

    static let sharedOperations = APIOperations()
}

class NetworkOperation: NSOperation {
    let URL: String
    let delegate: NetworkOperationDelegate?
    let networkOperationCompletionHandler: (responseObject: AnyObject?, error: NSError?) -> ()
    weak var request: Alamofire.Request?
    
    init(URL: String, delegate: NetworkOperationDelegate, networkOperationCompletionHandler:(responseObject: AnyObject?, error: NSError?) -> ()) {
        self.URL = URL
        self.delegate = delegate
        self.networkOperationCompletionHandler = networkOperationCompletionHandler
    }
    
    override func main() {
        request = Alamofire.request(.GET, URL, headers: ["Authorization": "Bearer \(Constants.GWAPI.token)"])
            .responseJSON { response in
                self.networkOperationCompletionHandler(responseObject: response.result.value, error: response.result.error)
        }
        delegate?.networkOperationFinished(self)
    }

    override func cancel() {
        request?.cancel()
        super.cancel()
    }
}

class ParseQueryOperation: NSOperation {
    
    let object: AnyObject?
    var delegate: ParseOperationDelegate?
    init(object: AnyObject?, delegate: ParseOperationDelegate) {
        self.object   = object
        self.delegate = delegate
    }
    
    override func main() {
        let responseJSON = JSON(self.object!)
        for (_, hit) in responseJSON {
            let id           = hit["_id"].stringValue
            let name         = hit["name"].stringValue
            let value        = hit["q"].stringValue
            let createdAt    = hit["createdAt"].stringValue
            let updatedAt    = hit["updatedAt"].stringValue
            let category     = hit["category"]["name"].stringValue
            let categoryID   = hit["category"]["_id"].stringValue
            
            let values: [String: AnyObject] = [
                "id"             : id,
                "name"           : name,
                "value"          : value,
                "createdAt"      : createdAt,
                "updatedAt"      : updatedAt,
                "category"       : category,
                "categoryID"     : categoryID,
            ]
            
            let realm = try! Realm()
            realm.beginWrite()
            realm.create(Query.self, value: values, update: true)
            try! realm.commitWrite()
        }
        self.delegate?.parseQueryOperationFinished(self)
    }
}

class ParseRegionOperation: NSOperation {
    let sharedUI = UIManager.sharedManager
    let URL: String!
    let object: AnyObject?
    let delegate: ParseOperationDelegate?
    
    init(object: AnyObject?, URL: String!, delegate: ParseOperationDelegate) {
        self.URL = URL
        self.object = object
        self.delegate = delegate
    }
    
    override func main() {
        if self.cancelled { return }
        let responseJSON = JSON(object!)
        
        for (_, hit) in responseJSON {
            
            let id        = hit["_id"].stringValue
            let name      = hit["name"].stringValue
            let state     = hit["state"].stringValue
            let country   = hit["country"].stringValue
            let active    = hit["active"].boolValue
            let places    = hit["counter"]["places"].intValue
            if places == 0 {
                
                continue
                
            }
            let maxValue = max(sharedUI.pageSize, places)
            sharedUI.pageSize = maxValue
            NSUserDefaults.standardUserDefaults().setInteger(maxValue, forKey: "pageSize")
            let online    = hit["counter"]["online"].intValue
            let events    = hit["counter"]["events"].intValue
            let image     = hit["image"]["secure_url"].stringValue
            let longitude = hit["geometry"]["coordinates"][0].doubleValue
            let latitude  = hit["geometry"]["coordinates"][1].doubleValue
            
            var media = false
            if image != "" { media = true }
            
            let values : [String : AnyObject] = [
                "id"        : id,
                "name"      : name,
                "state"     : state,
                "country"   : country,
                "active"    : active,
                "places"    : places,
                "online"    : online,
                "events"    : events,
                "image"     : image,
                "media"     : media,
                "latitude"  : latitude,
                "longitude" : longitude
            ]
            
            let realm = try! Realm()
            realm.beginWrite()
            realm.create(Region.self, value: values, update: true)
            try! realm.commitWrite()
        }
        self.delegate?.parseRegionOperationFinished(self)
        if self.cancelled { return }
    }
}

class ParseVenueDetailOperation: NSOperation {
    
    let URL: String!
    let object: AnyObject?
    var delegate: ParseOperationDelegate?
    let completionHandler:(value: [String: AnyObject]!) -> ()
    
    init(object: AnyObject?, delegate: ParseOperationDelegate?, URL: String!, completionHandler:(value: [String: AnyObject]!) -> ()) {
        self.URL = URL
        self.object = object
        self.delegate = delegate
        self.completionHandler = completionHandler
    }
    
    override func main() {
        
        let hit = JSON(self.object!)
        let id           = hit["_id"].stringValue
        let slug         = hit["slug"].stringValue
        let email        = hit["email"].stringValue
        let address2     = hit["addr2"].stringValue
        let updatedAt    = hit["updatedAt"].stringValue
        let website      = hit["website"].stringValue
        let crossStreet  = hit["crossStreet"].stringValue
        let openNow      = hit["openingHours"]["openNow"].boolValue
        let menu         = hit["menu"].stringValue
        let reservations = hit["reservations"].stringValue
        var parking = ""
        let garage = hit["parking"]["garage"].boolValue
        let street = hit["parking"]["street"].boolValue
        let lot    = hit["parking"]["lot"].boolValue
        let valet  = hit["parking"]["valet"].boolValue
        
        if garage == true {
            parking = "Garage"
        }
        if street == true {
            parking = parking + "\nStreet"
        }
        if lot == true {
            parking = parking + "\nLot"
        }
        if valet == true {
            parking = parking + "\nValet"
        }
        
        var paymentOptions = ""
        let visa       = hit["paymentOptions"]["visa"].boolValue
        let amex       = hit["paymentOptions"]["amex"].boolValue
        let discover   = hit["paymentOptions"]["discover"].boolValue
        let mastercard = hit["paymentOptions"]["mastercard"].boolValue
        
        if visa == true {
            paymentOptions = "Visa"
        }
        if amex == true {
            paymentOptions = paymentOptions + "\nAmex"
        }
        if discover == true {
            paymentOptions = paymentOptions + "\nDiscover"
        }
        if mastercard == true {
            paymentOptions = paymentOptions + "\nMastercard"
        }
        
        var attire = ""
        for (_, service) in hit["attire"] {
            let name = service["name"].stringValue
            attire = attire + "\n\(name)"
        }
        
        var products = ""
        for (_, product) in hit["products"] {
            let name = product["name"].stringValue
            products = products + "\n\(name)"
        }
        
        var menus = ""
        for (_, menu) in hit["menus"] {
            let name = menu["name"].stringValue
            menus = menus + "\n\(name)"
        }
        
        var workouts = ""
        for (_, service) in hit["workouts"] {
            let name = service["name"].stringValue
            workouts = workouts + "\n\(name)"
        }
        
        var amenities = ""
        for (_, service) in hit["amenities"] {
            let name = service["name"].stringValue
            amenities = amenities + "\n\(name)"
        }
        
        var peopleServed = ""
        for (_, people) in hit[peopleServed] {
            let name = people["name"].stringValue
            peopleServed = peopleServed + "\n\(name)"
        }
        
        var healingServices = ""
        for (_, service) in hit["healingServices"] {
            let name = service["name"].stringValue
            healingServices = healingServices + "\n\(name)"
        }
        
        var alcohol = ""
        for (_, service) in hit["alcohol"] {
            let name = service["name"].stringValue
            alcohol = alcohol + "\n\(name)"
        }
        
        var media = ""
        for (_, link) in hit["media"] {
            let url = link["secure_url"].stringValue
            media = media + "[\(url)]"
        }
        
        var types = ""
        for (_, type) in hit["type"] {
            types = types + "\n\(type)"
        }
        
        var openingHours = ""
        for (_, weekday) in hit["openingHours"]["weekdayText"] {
            openingHours = openingHours + "\n\(weekday.stringValue)"
        }
        
        var cuisines = ""
        for (_, cuisine) in hit["cuisine"] {
            let name = cuisine["name"].stringValue
            cuisines = cuisines + "\n\(name)"
        }
        
        var nutrition = ""
        for (_, fact) in hit["nutrition"] {
            let name = fact["name"].stringValue
            nutrition = nutrition + "\n\(name)"
        }
        
        var goodFor = ""
        for (_, good) in hit["goodFor"] {
            let name = good["name"].stringValue
            goodFor = goodFor + "\n\(name)"
        }
        
        var links = ""
        for (_, link) in hit["links"] {
            let name = link["name"].stringValue
            let url  = link["url"].stringValue
            links = links + "[\(name):::\(url)]"
        }
        if menu != "" {
            links = links + "[menu:::\(menu)]"
        }
        if reservations != "" {
            links = links + "[reservations:::\(reservations)]"
        }
        
        var eventType = ""
        for (_, type) in hit["eventType"] {
            let name = type["name"].stringValue
            eventType = eventType + "\n\(name)"
        }
        
        var reviews = ""
        for (_, review) in hit["reviews"] {
            let link = review["link"].stringValue
            let score = review["score"].stringValue
            let snippet = review["snippet"].stringValue
            let source = review["source"].stringValue
            reviews = reviews + "reviewmode: reviewsource: \(source) reviewscore: \(score) reviewlink: \(link) reviewsnippet: \(snippet) "
        }
        
        let eventLocation = hit["eventLocation"].stringValue
        let eventOrganizer = hit["eventOrganizer"].stringValue
        
        var eventDates = ""
        let start = hit["dates"][0]["startsAt"].stringValue
        let end = hit["dates"][0]["endsAt"].stringValue
        if start != "" && end != "" {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            let end = hit["dates"][0]["endsAt"].stringValue
            let startDate = formatter.dateFromString(start)
            let endDate   = formatter.dateFromString(end)
            formatter.dateFormat = "EEE, MMM dd, hh:mm a"
            let startsAt = formatter.stringFromDate(startDate!)
            let endsAt = formatter.stringFromDate(endDate!)
            eventDates = " \(startsAt):::\(endsAt)"
        }
        
        var onlineContent = ""
        for (_, object) in hit["content"] {
            let name = object["name"].stringValue
            onlineContent = onlineContent + "\n\(name)"
        }
        
        links           = links.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        media           = media.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        menus           = menus.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        attire          = attire.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        parking         = parking.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        alcohol         = alcohol.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        goodFor         = goodFor.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        cuisines        = cuisines.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        products        = products.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        workouts        = workouts.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        amenities       = amenities.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        eventType       = eventType.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        nutrition       = nutrition.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        openingHours    = openingHours.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        peopleServed    = peopleServed.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        paymentOptions  = paymentOptions.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        onlineContent   = onlineContent.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        reviews = reviews.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        healingServices = healingServices.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        
        let values: [String: AnyObject] = [
            "id"                 : id,
            "slug"               : slug,
            "email"              : email,
            "links"              : links,
            "type"               : types,
            "media"              : media,
            "menus"              : menus,
            "attire"             : attire,
            "alcohol"            : alcohol,
            "website"            : website,
            "goodFor"            : goodFor,
            "cuisines"           : cuisines,
            "crossStreet"        : crossStreet,
            "nutrition"          : nutrition,
            "address2"           : address2,
            "updatedAt"          : updatedAt,
            "parking"            : parking,
            "openNow"            : openNow,
            "workouts"           : workouts,
            "products"           : products,
            "amenities"          : amenities,
            "openingHours"       : openingHours,
            "peopleServed"       : peopleServed,
            "payment"            : paymentOptions,
            "onlineContent"      : onlineContent,
            "eventType"          : eventType,
            "eventDates"         : eventDates,
            "eventLocation"      : eventLocation,
            "eventOrganizer"     : eventOrganizer,
            "healingServices"    : healingServices,
            "reviews"            : reviews
        ]
        
        self.completionHandler(value: values)
        self.delegate?.parseVenueDetailOperationFinished(self)
        if self.cancelled { return }
    }
}

class ParseVenueListOperation: NSOperation {
    
    let URL: String!
    let object: AnyObject?
    var values: [[String: AnyObject]]?
    var delegate: ParseOperationDelegate?
    let completionHandler:(values: [[String: AnyObject]]!) -> ()
    
    init(object: AnyObject?, delegate: ParseOperationDelegate?, URL: String!, completionHandler:(values: [[String: AnyObject]]!) -> ()) {
        self.URL = URL
        self.object = object
        self.delegate = delegate
        self.values = [[String: AnyObject]]()
        self.completionHandler = completionHandler
    }
    override func main() {
        if self.cancelled { return }
        let responseJSON = JSON(self.object!)
        for (_, hit) in responseJSON["list"] {
            let id           = hit["_id"].stringValue
            let score        = hit["_score"].doubleValue
            let sort         = hit["_sort"][0].doubleValue
            let website      = hit["website"].stringValue
            let phone        = hit["phone"].stringValue
            let info         = hit["description"].stringValue
            let kind         = hit["kind"].stringValue
            let name         = hit["name"].stringValue
            let state        = hit["city"]["state"].stringValue
            let category     = hit["category"]["name"].stringValue
            let featured     = hit["featured"].boolValue
            let certified    = hit["certified"].boolValue
            let cost         = hit["cost"].intValue
            let rate         = hit["rating"].doubleValue
            let poster       = hit["poster"]["secure_url"].stringValue
            let media        = hit["media"]["secure_url"].stringValue
            let city         = hit["city"]["name"].stringValue
            let zip          = hit["zip"].stringValue
            let address1     = hit["addr1"].stringValue
            let regionID     = hit["region"]["_id"].stringValue
            let regionName   = hit["region"]["name"].stringValue
            let longitude    = hit["geometry"]["coordinates"][0].doubleValue
            let latitude     = hit["geometry"]["coordinates"][1].doubleValue
            let neighborhood = hit["neighborhoods"][0].stringValue
            let subcategory  = hit["subcategory"]["name"].stringValue
            
            let values: [String: AnyObject] = [
                "id"                 : id,
                "score"              : score,
                "info"               : info,
                "kind"               : kind,
                "name"               : name,
                "website"            : website,
                "phone"              : phone,
                "poster"             : poster,
                "media"              : media,
                "certified"          : certified,
                "featured"           : featured,
                "address1"           : address1,
                "zip"                : zip,
                "city"               : city,
                "state"              : state,
                "regionID"           : regionID,
                "regionName"         : regionName,
                "neighborhood"       : neighborhood,
                "subcategory"        : subcategory,
                "category"           : category,
                "longitude"          : longitude,
                "latitude"           : latitude,
                "rate"               : rate,
                "cost"               : cost,
                "sort"               : sort
            ]
            
            self.values?.append(values)
        }
        
        self.completionHandler(values: self.values)
        self.delegate?.parseVenueListOperationFinished(self)
        if self.cancelled { return }
    }
}

class ParseVenueOperation: NSOperation {
    
    let URL: String!
    let object: AnyObject?
    var delegate: ParseOperationDelegate?
    let completionHandler:(value: [String: AnyObject]!) -> ()
    
    init(object: AnyObject?, delegate: ParseOperationDelegate?, URL: String!, completionHandler:(value: [String: AnyObject]!) -> ()) {
        self.URL = URL
        self.object = object
        self.delegate = delegate
        self.completionHandler = completionHandler
    }
    override func main() {
        if self.cancelled { return }
        
        let hit = JSON(self.object!)
        let id           = hit["_id"].stringValue
        let slug         = hit["slug"].stringValue
        let email        = hit["email"].stringValue
        let score        = hit["_score"].doubleValue
        let sort         = hit["_sort"][0].doubleValue
        let website      = hit["website"].stringValue
        let phone        = hit["phone"].stringValue
        let info         = hit["description"].stringValue
        let kind         = hit["kind"].stringValue
        let name         = hit["name"].stringValue
        let state        = hit["city"]["state"].stringValue
        let category     = hit["category"]["name"].stringValue
        let featured     = hit["featured"].boolValue
        let certified    = hit["certified"].boolValue
        let cost         = hit["cost"].intValue
        let rate         = hit["rating"].doubleValue
        let poster       = hit["poster"]["secure_url"].stringValue
        let city         = hit["city"]["name"].stringValue
        let zip          = hit["zip"].stringValue
        let address1     = hit["addr1"].stringValue
        let regionID     = hit["region"]["_id"].stringValue
        let regionName   = hit["region"]["name"].stringValue
        let longitude    = hit["geometry"]["coordinates"][0].doubleValue
        let latitude     = hit["geometry"]["coordinates"][1].doubleValue
        let neighborhood = hit["neighborhoods"][0].stringValue
        let subcategory  = hit["subcategory"]["name"].stringValue
        
        let address2     = hit["addr2"].stringValue
        let updatedAt    = hit["updatedAt"].stringValue
        let crossStreet  = hit["crossStreet"].stringValue
        let openNow      = hit["openingHours"]["openNow"].boolValue
        let menu         = hit["menu"].stringValue
        let reservations = hit["reservations"].stringValue
        
        var parking = ""
        let garage = hit["parking"]["garage"].boolValue
        let street = hit["parking"]["street"].boolValue
        let lot    = hit["parking"]["lot"].boolValue
        let valet  = hit["parking"]["valet"].boolValue
        
        if garage == true {
            parking = "Garage"
        }
        if street == true {
            parking = parking + "\nStreet"
        }
        if lot == true {
            parking = parking + "\nLot"
        }
        if valet == true {
            parking = parking + "\nValet"
        }
        
        var paymentOptions = ""
        let visa       = hit["paymentOptions"]["visa"].boolValue
        let amex       = hit["paymentOptions"]["amex"].boolValue
        let discover   = hit["paymentOptions"]["discover"].boolValue
        let mastercard = hit["paymentOptions"]["mastercard"].boolValue
        
        if visa == true {
            paymentOptions = "Visa"
        }
        if amex == true {
            paymentOptions = paymentOptions + "\nAmex"
        }
        if discover == true {
            paymentOptions = paymentOptions + "\nDiscover"
        }
        if mastercard == true {
            paymentOptions = paymentOptions + "\nMastercard"
        }
        
        var attire = ""
        for (_, service) in hit["attire"] {
            let name = service["name"].stringValue
            attire = attire + "\n\(name)"
        }
        
        var products = ""
        for (_, product) in hit["products"] {
            let name = product["name"].stringValue
            products = products + "\n\(name)"
        }
        
        var menus = ""
        for (_, menu) in hit["menus"] {
            let name = menu["name"].stringValue
            menus = menus + "\n\(name)"
        }
        
        var workouts = ""
        for (_, service) in hit["workouts"] {
            let name = service["name"].stringValue
            workouts = workouts + "\n\(name)"
        }
        
        var amenities = ""
        for (_, service) in hit["amenities"] {
            let name = service["name"].stringValue
            amenities = amenities + "\n\(name)"
        }
        
        var peopleServed = ""
        for (_, people) in hit[peopleServed] {
            let name = people["name"].stringValue
            peopleServed = peopleServed + "\n\(name)"
        }
        
        var healingServices = ""
        for (_, service) in hit["healingServices"] {
            let name = service["name"].stringValue
            healingServices = healingServices + "\n\(name)"
        }
        
        var alcohol = ""
        for (_, service) in hit["alcohol"] {
            let name = service["name"].stringValue
            alcohol = alcohol + "\n\(name)"
        }
        
        var media = ""
        for (_, link) in hit["media"] {
            let url = link["secure_url"].stringValue
            media = media + "[\(url)]"
        }
        
        var types = ""
        for (_, type) in hit["type"] {
            types = types + "\n\(type)"
        }
        
        var openingHours = ""
        for (_, weekday) in hit["openingHours"]["weekdayText"] {
            openingHours = openingHours + "\n\(weekday.stringValue)"
        }
        
        var cuisines = ""
        for (_, cuisine) in hit["cuisine"] {
            let name = cuisine["name"].stringValue
            cuisines = cuisines + "\n\(name)"
        }
        
        var nutrition = ""
        for (_, fact) in hit["nutrition"] {
            let name = fact["name"].stringValue
            nutrition = nutrition + "\n\(name)"
        }
        
        var goodFor = ""
        for (_, good) in hit["goodFor"] {
            let name = good["name"].stringValue
            goodFor = goodFor + "\n\(name)"
        }
        
        var links = ""
        for (_, link) in hit["links"] {
            let name = link["name"].stringValue
            let url  = link["url"].stringValue
            links = links + "[\(name):::\(url)]"
        }
        if menu != "" {
            links = links + "[menu:::\(menu)]"
        }
        if reservations != "" {
            links = links + "[reservations:::\(reservations)]"
        }
        
        var eventType = ""
        for (_, type) in hit["eventType"] {
            let name = type["name"].stringValue
            eventType = eventType + "\n\(name)"
        }
        
        let eventLocation = hit["eventLocation"].stringValue
        let eventOrganizer = hit["eventOrganizer"].stringValue
        
        var eventDates = ""
        let start = hit["dates"][0]["startsAt"].stringValue
        let end = hit["dates"][0]["endsAt"].stringValue
        if start != "" && end != "" {
            let formatter = NSDateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            let end = hit["dates"][0]["endsAt"].stringValue
            let startDate = formatter.dateFromString(start)
            let endDate   = formatter.dateFromString(end)
            formatter.dateFormat = "EEE, MMM dd, hh:mm a"
            let startsAt = formatter.stringFromDate(startDate!)
            let endsAt = formatter.stringFromDate(endDate!)
            eventDates = " \(startsAt):::\(endsAt)"
        }
        
        var onlineContent = ""
        for (_, object) in hit["content"] {
            let name = object["name"].stringValue
            onlineContent = onlineContent + "\n\(name)"
        }
        
        let values: [String: AnyObject] = [
            "id"                 : id,
            "slug"               : slug,
            "email"              : email,
            "score"              : score,
            "info"               : info,
            "kind"               : kind,
            "name"               : name,
            "phone"              : phone,
            "poster"             : poster,
            "certified"          : certified,
            "featured"           : featured,
            "address1"           : address1,
            "zip"                : zip,
            "city"               : city,
            "state"              : state,
            "regionID"           : regionID,
            "regionName"         : regionName,
            "neighborhood"       : neighborhood,
            "subcategory"        : subcategory,
            "category"           : category,
            "longitude"          : longitude,
            "latitude"           : latitude,
            "rate"               : rate,
            "cost"               : cost,
            "sort"               : sort,
            "links"              : links,
            "type"               : types,
            "media"              : media,
            "menus"              : menus,
            "attire"             : attire,
            "alcohol"            : alcohol,
            "website"            : website,
            "goodFor"            : goodFor,
            "cuisines"           : cuisines,
            "crossStreet"        : crossStreet,
            "nutrition"          : nutrition,
            "address2"           : address2,
            "updatedAt"          : updatedAt,
            "parking"            : parking,
            "openNow"            : openNow,
            "workouts"           : workouts,
            "products"           : products,
            "amenities"          : amenities,
            "openingHours"       : openingHours,
            "peopleServed"       : peopleServed,
            "payment"            : paymentOptions,
            "onlineContent"      : onlineContent,
            "eventType"          : eventType,
            "eventDates"         : eventDates,
            "eventLocation"      : eventLocation,
            "eventOrganizer"     : eventOrganizer,
            "healingServices"    : healingServices
        ]
        
        self.completionHandler(value: values)
        self.delegate?.parseVenueOperationFinished(self)
        if self.cancelled { return }
    }
}
