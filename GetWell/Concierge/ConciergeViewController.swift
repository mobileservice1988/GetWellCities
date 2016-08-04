//
//  ConciergeViewController.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import UIKit
import Intercom
import Localytics

class ConciergeViewController: UIViewController {

    @IBOutlet weak var chatButton: UIButton!
    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    @IBAction func chatButtonPressed(sender: AnyObject) {
        showHistory()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        super.viewDidAppear(animated)
        Localytics.tagScreen("Concierge")
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
        super.viewDidAppear(animated)
        if appDelegate.quickConcierge == 1 {
            showHistory()
            appDelegate.quickConcierge = 0
        }
    }
    
    func showHistory() {
        Intercom.presentMessenger()
        Localytics.tagEvent("ChatStarted")
    }
    
}