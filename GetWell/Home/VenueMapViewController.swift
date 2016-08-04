
//  VenueMapViewController.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import UIKit
import Mapbox
import Foundation
import Localytics
import RealmSwift

class VenueMapViewController: UIViewController, MGLMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var mapCollectionView: UICollectionView!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var areaSearchButton: UIButton!
    
    @IBAction func areaSearchButtonTapped(sender: AnyObject) {
        let distance = determineDistance(centerPoint!, locationTwo: northWestPoint!)
        performSearchForArea(centerPoint!, radius: distance)
    }
    
    @IBAction func locationButtonTapped(sender: AnyObject) {
        toggleLocation()
    }
    
    let sharedUI     = UIManager.sharedManager
    let sharedAPI    = APIManager.sharedManager
    let sharedStack  = RealmStack.sharedStack
    
    let realm = try! Realm()
    var visibleAnnotations = [MGLAnnotation]()
    
    var lastZoomLevel: Double?
    var lastCenterPoint: CLLocationCoordinate2D?
    
    var centerPoint: CLLocationCoordinate2D?
    var northWestPoint: CLLocationCoordinate2D?
    var collectionViewFrame: CGRect?
    
    var filters: [String] = []
    var cutMaps: [Venue] = []
    var venues: [Venue] = []
    var region: Region? {
        didSet {
            updateFilters()
        }
    }

    override func viewDidLoad() {
        updateMap()
        super.viewDidLoad()
        mapCollectionView.delegate = self
        mapCollectionView.dataSource = self
        mapCollectionView.backgroundColor = UIColor.clearColor()
        locationButton.tintColor = sharedUI.colorMain
        collectionViewFrame = mapCollectionView.frame
        title = region!.name
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Localytics.tagScreen("PlaceMap")
    }
    
    func performSearchForArea(coordinate: CLLocationCoordinate2D, radius: Double) {
        sharedAPI.getDataForMapArea(coordinate, radius: radius, filters: filters) { (venues) in
            if venues!.count != 0 {
                self.hideSearchButton()
                self.venues.removeAll()
                self.venues = venues!
                dispatch_async(dispatch_get_main_queue(), {
                    self.showSearchButton()
                    self.setupAnnocations(venues!)
                    self.mapCollectionView.reloadData()
                    self.mapView.selectAnnotation(self.mapView.annotations!.first!, animated: true)
                    if self.mapCollectionView.hidden {
                        self.mapCollectionView.hidden = false
                    }
                })
            }
            else {
                self.showVenuesFoundAlert()
            }
        }
    }
    
    func showVenuesFoundAlert() {
        dispatch_async(dispatch_get_main_queue(), {
            let alert = UIAlertController(title: "Whoops!", message: "Please search in another area of the map.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            if !self.mapCollectionView.hidden {
                self.mapCollectionView.hidden = true
            }
        })
    }
    
    func updateFilters() {
        var defaultFilters: [String] = []
        if NSUserDefaults.standardUserDefaults().boolForKey("switchEatState")  { defaultFilters.append("eat")  }
        if NSUserDefaults.standardUserDefaults().boolForKey("switchMoveState") { defaultFilters.append("move") }
        if NSUserDefaults.standardUserDefaults().boolForKey("switchHealState") { defaultFilters.append("heal") }
        let cost = NSUserDefaults.standardUserDefaults().integerForKey("currentCost")
        let price = NSUserDefaults.standardUserDefaults().doubleForKey("currentRating")
        defaultFilters.append("cost:[\(cost)+TO+5]")
        defaultFilters.append("rating:[\(price)+TO+5]")
        filters = defaultFilters
        if defaultFilters.count == 5 && cost == 0 && price == 0{
            filters = []
        }
    }
    func cutvenues(){
        if self.venues.count > sharedUI.mapsize {
            self.venues = Array(self.venues.prefix(sharedUI.mapsize))
            NSLog("log")
        }
        
    }
    func updateMap() {
        mapView.maximumZoomLevel = 14
        mapView.logoView.hidden = true
        mapView.attributionButton.hidden = true
        mapView.delegate = self
        cutvenues()
        setupAnnocations(self.venues)
    }
    
    func mapViewDidFinishRenderingMap(mapView: MGLMapView, fullyRendered: Bool) {
        if fullyRendered {
            if mapView.centerCoordinate.longitude < -2.0 {
                if lastCenterPoint == nil {
                    lastCenterPoint = mapView.centerCoordinate
                    lastZoomLevel = mapView.zoomLevel
                    mapView.maximumZoomLevel = 17
                    mapView.selectAnnotation(mapView.annotations!.first!, animated: true)
                }
            }
        }
    }
    
    func mapView(mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        centerPoint = mapView.centerCoordinate
        northWestPoint = mapView.visibleCoordinateBounds.ne
        if lastCenterPoint != nil {
            let distance = checkCenterPointDistance(mapView.centerCoordinate)
            if distance > 0.20 {
                self.showSearchButton()
            }
            if mapView.zoomLevel-1 > lastZoomLevel! {
                self.showSearchButton()
            }
            if mapView.zoomLevel+1 < lastZoomLevel! {
                self.showSearchButton()
            }
        }
    }
    
    func mapViewDidFinishLoadingMap(mapView: MGLMapView) {
        if mapView.annotations!.count > 0 {
            dispatch_async(dispatch_get_main_queue(), {
                mapView.showAnnotations(mapView.annotations!, edgePadding: UIEdgeInsetsMake(50, 50, 50, 50), animated: true)
            })
        }
    }
    
    func mapView(mapView: MGLMapView, didSelectAnnotation annotation: MGLAnnotation) {
        let annotationCoordinate = annotation.coordinate
        for (index, venue) in venues.enumerate() {
            let coordinate = CLLocationCoordinate2DMake(venue.latitude, venue.longitude)
            if annotationCoordinate.latitude == coordinate.latitude && annotationCoordinate.longitude == coordinate.longitude {
                let indexPath = NSIndexPath(forItem: index, inSection: 0)
                dispatch_async(dispatch_get_main_queue(), {
                    self.mapCollectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
                })
            }
        }
    }
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        if annotation.isKindOfClass(MAPPointEatAnnotation) {
            var annotationImage  = mapView.dequeueReusableAnnotationImageWithIdentifier("eat")
            if annotationImage == nil {
                var image = UIImage(named: "icon-Marker-Eat")!
                image = image.imageWithAlignmentRectInsets(UIEdgeInsetsMake(0, 0, image.size.height/2, 0))
                annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "eat")
            }
            return annotationImage
        }
        if annotation.isKindOfClass(MAPPointMoveAnnotation) {
            var annotationImage  = mapView.dequeueReusableAnnotationImageWithIdentifier("move")
            if annotationImage == nil {
                var image = UIImage(named: "icon-Marker-Move")!
                image = image.imageWithAlignmentRectInsets(UIEdgeInsetsMake(0, 0, image.size.height/2, 0))
                annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "move")
            }
            return annotationImage
        }
        if annotation.isKindOfClass(MAPPointHealAnnotation) {
            var annotationImage  = mapView.dequeueReusableAnnotationImageWithIdentifier("heal")
            if annotationImage == nil {
                var image = UIImage(named: "icon-Marker-Heal")!
                image = image.imageWithAlignmentRectInsets(UIEdgeInsetsMake(0, 0, image.size.height/2, 0))
                annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "heal")
            }
            return annotationImage
        }
        return nil
    }
    
    func setupAnnocations(venues: [Venue]!) {
        visibleAnnotations.removeAll()
        for venue: Venue in venues {
            let category = venue.category.lowercaseString
            if category == "eat" {
                let eat = MAPPointEatAnnotation()
                eat.coordinate = CLLocationCoordinate2DMake(venue.latitude, venue.longitude)
                eat.title    = venue.name
                eat.subtitle = "\(venue.address1)"
                
                visibleAnnotations.append(eat)
            }
            if category == "move" {
                let move = MAPPointMoveAnnotation()
                move.coordinate = CLLocationCoordinate2DMake(venue.latitude, venue.longitude)
                move.title    = venue.name
                move.subtitle = "\(venue.address1)"
                visibleAnnotations.append(move)
            }
            if category == "heal" {
                let heal = MAPPointHealAnnotation()
                heal.coordinate = CLLocationCoordinate2DMake(venue.latitude, venue.longitude)
                heal.title    = venue.name
                heal.subtitle = "\(venue.address1)"
                visibleAnnotations.append(heal)
            }
        }
        if mapView.annotations != nil {
            mapView.removeAnnotations(mapView.annotations!)
        }
        mapView.addAnnotations(visibleAnnotations)
    }
    
    func clearAnnotations() {
        if mapView.annotations != nil {
            if mapView.annotations!.count > 0 {
                mapView.removeAnnotations(mapView.annotations!)
            }
        }
    }
    
    func toggleLocation() {
        if mapView.userTrackingMode == .None {
            mapView.setUserTrackingMode(.Follow, animated: true)
        }
        else {
            mapView.setUserTrackingMode(.None, animated: true)
            mapView.showsUserLocation = false
        }
    }
    
    func showSearchButton() {
        if areaSearchButton.hidden {
            dispatch_async(dispatch_get_main_queue(), {
                UIView.animateWithDuration(0.2, animations: {
                    self.areaSearchButton.alpha = 1.0
                    }, completion: { (value: Bool) in
                        self.areaSearchButton.hidden = false
                })
            })
        }
    }
    
    func hideSearchButton() {
        lastCenterPoint = mapView.centerCoordinate
        lastZoomLevel = mapView.zoomLevel
        if !areaSearchButton.hidden {
            dispatch_async(dispatch_get_main_queue(), {
                UIView.animateWithDuration(0.2, animations: {
                    self.areaSearchButton.alpha = 0.0
                    }, completion: { (value: Bool) in
                        self.areaSearchButton.hidden = true
                })
            })
        }
    }
    
    func containsCoordinate(coordinate: CLLocationCoordinate2D) -> Bool! {
        let southWest = mapView.visibleCoordinateBounds.sw
        let northEast = mapView.visibleCoordinateBounds.ne
        return (coordinate.latitude >= southWest.latitude && coordinate.latitude <= northEast.latitude
            && coordinate.longitude >= southWest.longitude && coordinate.longitude <= northEast.longitude)
    }
    
    func checkCenterPointDistance(currentCenter: CLLocationCoordinate2D) -> Double {
        let currentCenter = CLLocation(latitude: currentCenter.latitude, longitude: currentCenter.longitude)
        let initialCenter = CLLocation(latitude: lastCenterPoint!.latitude, longitude: lastCenterPoint!.longitude)
        return currentCenter.distanceFromLocation(initialCenter) * 0.0001371192
    }
    
    func checkForVisibleAnnotations() {
        for (index, venue) in venues.enumerate() {
            let coordinate = CLLocationCoordinate2D(latitude: venue.latitude, longitude: venue.longitude)
            if !containsCoordinate(coordinate) {
                venues.removeAtIndex(index)
            }
        }
    }
    
    func getCernterCoordinate() -> CLLocationCoordinate2D {
        return mapView.centerCoordinate
    }
    
    func getTopCenterCoordinate() -> CLLocationCoordinate2D {
        return mapView.visibleCoordinateBounds.ne
    }
    
    func determineDistance(locationOne: CLLocationCoordinate2D, locationTwo: CLLocationCoordinate2D) -> Double {
        let center = CLLocation(latitude: locationOne.latitude, longitude: locationOne.longitude)
        let edge = CLLocation(latitude: locationTwo.latitude, longitude: locationTwo.longitude)
        return center.distanceFromLocation(edge) * 0.000621371192
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(collectionView.bounds.size.width - 26, CGFloat(76))
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! MapCollectionViewCell
        sharedStack.checkVenue(cell.venue) { (venue) in
            self.performSegueWithIdentifier("showVenueDetailSegue", sender: venue)
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return venues.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MapCollectionCell", forIndexPath: indexPath) as! MapCollectionViewCell
        cell.indexPath = indexPath
        cell.venue = venues[indexPath.item]
        return cell
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        for cell in mapCollectionView.visibleCells() {
            let indexPath = mapCollectionView.indexPathForCell(cell)
            let mapCell = mapCollectionView.cellForItemAtIndexPath(indexPath!) as! MapCollectionViewCell
            for annotation: MGLAnnotation in self.visibleAnnotations {
                let annotationCoordinate = annotation.coordinate
                let coordinate = CLLocationCoordinate2DMake(mapCell.venue.latitude, mapCell.venue.longitude)
                if coordinate.latitude == annotationCoordinate.latitude && coordinate.longitude == annotationCoordinate.longitude {
                    self.mapView.selectAnnotation(annotation, animated: true)
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showVenueDetailSegue" {
            let controller = segue.destinationViewController as? VenueDetailViewController
            controller!.venue = sender as? Venue
        }
    }

    
    //    func setupAnnotation(venue: Venue) -> MGLPointAnnotation {
    //        var annotation = MGLPointAnnotation()
    //        let category = venue.category.lowercaseString
    //        if category == "eat" {
    //            let eat = MAPPointEatAnnotation()
    //            eat.coordinate = CLLocationCoordinate2DMake(venue.latitude, venue.longitude)
    //            eat.title    = venue.name
    //            eat.subtitle = "\(venue.address1), \(venue.zip)"
    //            annotation = eat
    //        }
    //        if category == "move" {
    //            let move = MAPPointMoveAnnotation()
    //            move.coordinate = CLLocationCoordinate2DMake(venue.latitude, venue.longitude)
    //            move.title    = venue.name
    //            move.subtitle = "\(venue.address1), \(venue.zip)"
    //            annotation = move
    //        }
    //        if category == "heal" {
    //            let heal = MAPPointHealAnnotation()
    //            heal.coordinate = CLLocationCoordinate2DMake(venue.latitude, venue.longitude)
    //            heal.title    = venue.name
    //            heal.subtitle = "\(venue.address1), \(venue.zip)"
    //            annotation = heal
    //        }
    //        return annotation
    //    }
    
    
}
