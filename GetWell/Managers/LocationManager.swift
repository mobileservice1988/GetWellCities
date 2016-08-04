//
//  LocationManager.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import RealmSwift
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let sharedManager = LocationManager()
    
    let realm      = try! Realm()
    let sharedUI   = UIManager.sharedManager
    let sharedAuth = AuthManager.sharedManager
    
    var city = "new york"
    var region: CLPlacemark?
    var regions = false
    
    let geocoder = CLGeocoder()
    let locale = NSLocale.currentLocale()
    var locationManager: CLLocationManager!
    var status: CLAuthorizationStatus = .NotDetermined
    
    var currentLocation: CLLocation! {
        didSet {
            if !regions {
                regions = true
                defineCurrentRegion()
                RealmStack.sharedStack.calculateRegionDistance()
            }
        }
    }
    
    func startManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.activityType = .Fitness
            locationManager.distanceFilter = kCLDistanceFilterNone
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.allowsBackgroundLocationUpdates = false
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        self.status = status
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let newLocation = locations.last!
        if currentLocation == nil {
            currentLocation = newLocation
        }
        
        if newLocation.verticalAccuracy < 0 {
            return
        }
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        let locationAge: NSTimeInterval = -newLocation.timestamp.timeIntervalSinceNow
        if locationAge > 5.0 {
            return
        }
        
        if newLocation.horizontalAccuracy <= 10 {
            currentLocation = newLocation
        }
    }
    
    func defineCurrentRegion() {
        if currentLocation != nil {
            geocoder.reverseGeocodeLocation(currentLocation!) { (placemarks, error) in
                if placemarks != nil {
                    self.region = placemarks?.first
                    self.city = self.region!.locality!
                }
            }
        }
        
    }
    
    func mapRectForBounds(sw: CLLocationCoordinate2D, ne: CLLocationCoordinate2D) -> MKMapRect {
        
        let pointNE = MKMapPointForCoordinate(ne)
        let pointSW = MKMapPointForCoordinate(sw)
        let antimeridianOveflow = (ne.longitude > sw.longitude) ? 0 : MKMapSizeWorld.width
        return MKMapRectMake(pointSW.x, pointNE.y, (pointNE.x - pointSW.x) + antimeridianOveflow, (pointSW.y - pointNE.y))
    }

    func returnDistance(lat: Double, lng: Double) -> Double {
        let poi = CLLocation(latitude: lat, longitude: lng)
        return currentLocation.distanceFromLocation(poi) * 0.00062137
    }
    
    func inBounds(venues: [Venue], sw: CLLocationCoordinate2D, ne: CLLocationCoordinate2D, completion:(venues: [Venue]) -> Void) {
        let mapRect: MKMapRect = mapRectForBounds(sw, ne: ne)
        var hits = [Venue]()
        var index: Int = 0
        if venues.count > 200 {
            index = 200
        }
        else {
            index = venues.count - 1
        }
        
        for venue: Venue in venues[0...index] {
            let point = MKMapPointForCoordinate(CLLocationCoordinate2DMake(venue.latitude, venue.longitude))
            if MKMapRectContainsPoint(mapRect, point) {
                hits.append(venue)
            }
        }
        completion(venues: hits)
    }
    
}