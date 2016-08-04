//
//  SplashViewController.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    let sharedAuth = AuthManager.sharedManager
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController!.tabBar.hidden = true
        if sharedAuth.isLoggedIn() {
            let isRegionSelected = NSUserDefaults.standardUserDefaults().boolForKey("isRegionSelected")
            if isRegionSelected {
                performSegueWithIdentifier("showInitialViewSegue", sender: nil)
            } else {
                performSegueWithIdentifier("showRegionSelector", sender: nil)
            }
//            performSegueWithIdentifier("showInitialViewSegue", sender: nil)
//            performSegueWithIdentifier("showRegionSelector", sender: nil)
        }
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }


}
