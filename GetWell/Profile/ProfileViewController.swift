//
//  ProfileViewController.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import UIKit
import Intercom
import Localytics
import RealmSwift


class ProfileViewController: UITableViewController {
    
    let realm = try! Realm()
    let sharedUI       = UIManager.sharedManager
    let sharedAuth     = AuthManager.sharedManager
    let sharedLocation = LocationManager.sharedManager
    let sharedStack      = RealmStack.sharedStack
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var profileAvatarView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = sharedUI.colorBackground
        clearsSelectionOnViewWillAppear = true
        let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as? String
        versionLabel.text = "Version \(version!)"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Localytics.tagScreen("Profile")
    }
    
    override func viewWillAppear(animated: Bool) {
        configureProfileView()
        self.tableView.reloadData()
        super.viewWillAppear(animated)
    }

    func configureProfileView() {
        self.profileAvatarView.clipsToBounds = true
        self.profileAvatarView.layer.cornerRadius = 48
        if sharedAuth.isLoggedIn() {
            sharedAuth.userProfile { (profile) -> Void in
                self.profileAvatarView.sd_setImageWithURL(profile.picture)
                self.profileAvatarView.contentMode = .ScaleAspectFill
                self.profileNameLabel.text = profile.name
            }
        }
        else {
            self.profileAvatarView.image           = sharedUI.imageProfile
            self.profileAvatarView.tintColor       = UIColor.whiteColor()
            self.profileAvatarView.contentMode     = .ScaleAspectFill
            self.profileAvatarView.backgroundColor = UIColor (red: 0.6939, green: 0.6887, blue: 0.7271, alpha: 1.0)
            self.profileNameLabel.text = "Google or Facebook"
        }
        self.profileNameLabel.kerning = 0.33
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 3 {
            let searches = realm.objects(Search)
            if searches.count == 0 {
                cell.userInteractionEnabled = false
                cell.contentView.alpha = 0.4
            }
            else {
                cell.userInteractionEnabled = true
                cell.contentView.alpha = 1.0
            }
        }
        if indexPath.row != 3 && indexPath.row != 4 {
            cell.layoutMargins      = UIEdgeInsetsZero
            let accessoryView       = UIImageView(image: sharedUI.imageDisclose)
            accessoryView.tintColor = sharedUI.colorMain
            cell.accessoryView      = accessoryView
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row == 0 {
            performSegueWithIdentifier("showWebViewSegue", sender:Constants.GWAPI.helpURL)
        }
        if indexPath.row == 1 {
            performSegueWithIdentifier("showWebViewSegue", sender:Constants.GWAPI.acknowledgmentURL)
        }
        if indexPath.row == 2 {
            performSegueWithIdentifier("showWebViewSegue", sender:Constants.GWAPI.legalURL)
        }
        if indexPath.row == 3 {
            showAlertForSearch({ (status) in
                if status {
                    self.realm.beginWrite()
                    self.realm.delete(self.realm.objects(Search))
                    try! self.realm.commitWrite()
                    self.tableView.reloadData()
                }
            })
        }
        if indexPath.row == 4 {
            navigateHomeView()
        }
        if indexPath.row == 5 {
            if sharedAuth.isLoggedIn() {
                showAlertForLogout({ (status) in
                    if status {
                        Intercom.reset()
                        self.sharedAuth.keychain.clearAll()
                        self.sharedAuth.lock.clearSessions()
                        self.configureProfileView()
                        self.appDelegate.logoutAuth()
                        Localytics.tagCustomerLoggedOut([:])
                    }
                    else {}
                })
            }
        }
    }
    func navigateHomeView() {
        sharedStack.initializeDefaultRegion()
        NSUserDefaults.standardUserDefaults().setBool(false, forKey: "isRegionSelected")
        tabBarController?.selectedIndex = 0
        let vwController = tabBarController?.selectedViewController as! UINavigationController
        vwController.popToRootViewControllerAnimated(true);
    }
    func showAlertForSearch(completion:(status: Bool) -> Void) {
        let alert = UIAlertController(
            title: "Are you sure?",
            message: nil,
            preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (test) -> Void in
            completion(status: false)
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Yes, I'm sure", style: .Default, handler: { (test) -> Void in
            completion(status: true)
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func showAlertForLogout(completion:(status: Bool) -> Void) {
        let alert = UIAlertController(
            title: "Are you sure?",
            message: nil,
            preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (test) -> Void in
            completion(status: false)
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Log out", style: .Default, handler: { (test) -> Void in
            completion(status: true)
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showWebViewSegue" {
            let controller = segue.destinationViewController as? WebViewController
            controller?.hidesBottomBarWhenPushed = true
            let URL = sender as? String
            controller?.URL = NSURL(string: URL!)
            if URL!.containsString("legal") { controller?.title = "Legal" }
            if URL!.containsString("help")  { controller?.title = "Help"  }
            if URL!.containsString("acknowledgment")  { controller?.title = "Acknowledgments"  }

        }
    }

}