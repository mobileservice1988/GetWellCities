//
//  FavoriteViewController.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import UIKit
import Localytics

class FavoriteViewController: UITableViewController, VenueCellDelegate {
    
    let sharedUI = UIManager.sharedManager
    let sharedStack = RealmStack.sharedStack
    var featuredVenues = [Venue]()
    var favoriteVenues = [Venue]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateFeatured()
        updateFavorites()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "VenueCell", bundle: nil), forCellReuseIdentifier: "VenueCell")
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Localytics.tagScreen("FavoriteList")
    }
    
    func updateFeatured() {
        featuredVenues = sharedStack.featuredVenues()!.toArray()
        UIView.transitionWithView(tableView,
                                  duration: 0.2,
                                  options: .TransitionCrossDissolve,
                                  animations:
            { () -> Void in
                self.tableView.reloadData()
            },
                                  completion: nil)
    }
    
    func updateFavorites() {
        favoriteVenues = sharedStack.favoriteVenues()!.toArray()
        UIView.transitionWithView(tableView,
                                  duration: 0.2,
                                  options: .TransitionCrossDissolve,
                                  animations:
            { () -> Void in
                self.tableView.reloadData()
            },
                                  completion: nil);
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 48
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 430
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 430
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view: UITableViewCell?
        if section == 0 {
            view = tableView.dequeueReusableCellWithIdentifier("headerFeature")! as UITableViewCell
        }
        if section == 1 {
            view = tableView.dequeueReusableCellWithIdentifier("headerFavorite")! as UITableViewCell
        }
        return view
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)! as! VenueTableViewCell
        performSegueWithIdentifier("showVenueDetailSegue", sender: cell.venue)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return featuredVenues.count
        }
        if section == 1 {
            return favoriteVenues.count
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VenueCell", forIndexPath: indexPath) as! VenueTableViewCell
        if indexPath.section == 0 {
            cell.venue = featuredVenues[indexPath.row]
        }
        if indexPath.section == 1 {
            cell.venue = favoriteVenues[indexPath.row]
        }
        if cell.delegate == nil {
            cell.delegate = self
        }
        return cell
    }
    
    func cellFavoriteButtonTapped(cell: VenueTableViewCell) {
        let venue  = cell.venue
        let button = cell.favoriteButton
        if !venue.favorite {
            sharedStack.favoriteCheck(venue)
            button.selected = !button.selected
            button.tintColor = cell.color
            updateFeatured()
            updateFavorites()
        }
        else {
            showAlertForVenue(venue.name, completion: { (status) in
                if status {
                    self.sharedStack.favoriteCheck(venue)
                    button.selected = !button.selected
                    button.tintColor = UIColor.whiteColor()
                    self.updateFeatured()
                    self.updateFavorites()
                }
            })
        }
    }
    
    func showAlertForVenue(title: String!, completion:(status: Bool) -> Void) {
        let alert = UIAlertController(
            title: "\(title)",
            message: "Are you sure you want to remove this item from favorites?",
            preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (test) -> Void in
            completion(status: false)
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Remove", style: .Default, handler: { (test) -> Void in
            completion(status: true)
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showVenueDetailSegue" {
            let viewcontroller = segue.destinationViewController as? VenueDetailViewController
            viewcontroller!.venue = sender as? Venue
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}
