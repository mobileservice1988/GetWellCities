//
//  VenueListViewController.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import UIKit
import RealmSwift
import Localytics
import CoreLocation

class VenueListViewController: UITableViewController, VenueCellDelegate {
    
    @IBAction func unwindToVenueList(segue: UIStoryboardSegue) {}
    
    @IBAction func filterButtonPressed(sender: AnyObject) {
        presentFilterView()
    }
    @IBAction func mapButtonPressed(sender: AnyObject)    {
        presentMapView()
    }
    var filterResultsLabel: UILabel!
    
    let realm = try! Realm()
    let sharedUI    = UIManager.sharedManager
    let sharedAPI   = APIManager.sharedManager
    let sharedStack = RealmStack.sharedStack
    
    var filters: [String] = [] {
        didSet {
            venues.removeAll()
            let cost = NSUserDefaults.standardUserDefaults().integerForKey("currentCost")
            let price = NSUserDefaults.standardUserDefaults().doubleForKey("currentRating")
            if filters.count == 5 && cost == 0 && price == 0{
                filters = []
            }
            getVenues(0, filters: filters)
        }
    }
    
    var lastLoadedPage = 0
    var venues: [Venue] = [] {
        didSet {
            reloadData()
        }
    }

    var region: Region? {
        didSet {
            checkFilters()
        }
    }
    
    func checkFilters() {
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
//        if defaultFilters.count == 3 {
//            filters = []
//        }
//        else {
//            filters = defaultFilters
//        }
    }
    
    func updateFilters(filters: [String]) {
        getVenues(0, filters: filters)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = region!.name
        tableView.registerNib(UINib(nibName: "VenueCell", bundle: nil), forCellReuseIdentifier: "VenueCell")
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        reloadData()
        Localytics.tagScreen("PlaceList")
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = false
        super.viewWillAppear(animated)
        tableView.reloadData()
        reloadData()
    }
    func setupFooterSpinner() {
        let view = UIView(frame: CGRectMake(0, 0, tableView.frame.width, 100))
        view.backgroundColor = sharedUI.colorBackground
        let pagingSpinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        pagingSpinner.center = view.center
        pagingSpinner.startAnimating()
        pagingSpinner.color = UIColor(red: 179.0/255.0, green: 179.0/255.0, blue: 179.0/255.0, alpha: 1.0)
        pagingSpinner.hidesWhenStopped = true
        view.addSubview(pagingSpinner)
        tableView.tableFooterView = view
        tableView.tableFooterView?.hidden = true
//        tableView.tableFooterView?.hidden = false
    }
    
    func getVenues(page: Int, filters: [String]) {
        lastLoadedPage = page
        let regionID = self.region!.id
        sharedAPI.getDataForPage(page, regionID: regionID, filters: filters) { (venues) in
            if venues!.count == 0 {
                dispatch_async(dispatch_get_main_queue(), {
                    let alert = UIAlertController(title: "No Places Found", message: "Please try another combination of filters.", preferredStyle: .Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                })
            }
            else {
                if self.venues.count > 0 {
                    self.venues.appendContentsOf(venues!)
                }
                else {
                    self.venues = venues!
                }
//                self.filterResultsLabel.text = "\(self.venues.count) results"
            }
        }
    }
    
    func reloadData() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView.tableFooterView?.hidden = true
            self.tableView.reloadData()
        })
    }
    
    func presentFilterView() {
        performSegueWithIdentifier("presentFilterViewSegue", sender: nil)
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableCellWithIdentifier("SectionHeader")! as UITableViewCell
        self.filterResultsLabel = view.viewWithTag(100) as! UILabel
        if self.venues.count > 0 {
            self.filterResultsLabel.text = "\(self.venues.count) Places"
        }        
        return view
    }
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues.count
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 430
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 430
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)! as! VenueTableViewCell
        sharedStack.checkVenue(cell.venue) { (venue) in
            self.performSegueWithIdentifier("showVenueDetailSegue", sender: venue)
        }
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VenueCell", forIndexPath: indexPath) as! VenueTableViewCell
        let nextPage = Int(indexPath.row / sharedUI.pageSize) + 1
        if (indexPath.row >= (nextPage * sharedUI.pageSize - sharedUI.preloadSize) && lastLoadedPage < nextPage) {
            getVenues(nextPage, filters: filters)
//            tableView.tableFooterView?.hidden = false
        }
        cell.venue = venues[indexPath.row]
        if cell.delegate == nil {
            cell.delegate = self
        }
        
        return cell
    }    
    func cellFavoriteButtonTapped(cell: VenueTableViewCell) {
        let venue  = cell.venue
        let button = cell.favoriteButton
        saveFavoriteVenue(venue, favorite: !button.selected)
        button.selected = !button.selected
        if button.selected {
            button.tintColor = cell.color!
        }
        else {
            button.tintColor = UIColor.whiteColor()
        }
    }
    
    func saveFavoriteVenue(venue: Venue!, favorite: Bool) {
        realm.beginWrite()
        venue.favorite = favorite
        realm.create(Venue.self, value: venue, update: true)
        try! realm.commitWrite()
    }
    
    func presentMapView() {
        performSegueWithIdentifier("presentMapSegue", sender: self.venues)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "presentMapSegue" {
            let nc = segue.destinationViewController as! UINavigationController
            let viewcontroller = nc.topViewController as? VenueMapViewController
            viewcontroller?.region = self.region
            viewcontroller?.venues = sender as! [Venue]
        }
        if segue.identifier == "showVenueDetailSegue" {
            let viewcontroller = segue.destinationViewController as? VenueDetailViewController
            viewcontroller?.hidesBottomBarWhenPushed = true
            viewcontroller!.venue = sender as? Venue
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
