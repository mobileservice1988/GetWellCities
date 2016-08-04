//
//  AppDelegate.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import UIKit
import Fabric
import Mapbox
import Intercom
import TwitterKit
import RealmSwift
import Localytics
import Crashlytics
import LockFacebook

enum Shortcut: String {
    case openSearch = "OpenSearch"
    case openConcierge = "OpenConcierge"
}

@UIApplicationMain class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate {

    var window: UIWindow? //test
    var quickSearch = 0
    var quickConcierge = 0
    let sharedAPI = APIManager.sharedManager
    let sharedAuth = AuthManager.sharedManager
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        Localytics.integrate(Constants.Localytics.key)
        
        if application.applicationState != .Background {
            Localytics.openSession()
        }
        
        UIManager.sharedManager
        RealmStack.sharedStack
        Fabric.with([Answers.self, Crashlytics.self, Twitter.self, MGLAccountManager.self])

        Intercom.setApiKey(Constants.Intercom.appKey, forAppId: Constants.Intercom.appID)
//      Intercom.setMessagesHidden(true)
        Intercom.setInAppMessagesVisible(true)
        
        sharedAuth.lock.applicationLaunchedWithOptions(launchOptions)
        if !userDefaults.boolForKey("FirstRun") {
            sharedAuth.keychain.clearAll()
            userDefaults.setBool(true, forKey: "FirstRun")
            userDefaults.setBool(true, forKey: "switchEatState")
            userDefaults.setBool(true, forKey: "switchMoveState")
            userDefaults.setBool(true, forKey: "switchHealState")
            userDefaults.synchronize()
        }
        if !sharedAuth.isLoggedIn() {
            showAuthFlow(false)
        }
        else {
            sharedAuth.userProfile({ (profile) -> Void in })
            if !self.sharedAuth.permissionRequested {
                self.sharedAuth.requestPermission()
                customizeAppearance()
                self.sharedAuth.permissionRequested = true
            }
        }
        
//        Intercom.enableLogging()
//        Localytics.setLoggingEnabled(true)
        
        return true
    }
    
    func showAuthFlow(animated: Bool) {
        let storyboard = UIStoryboard(name: "AuthFlow", bundle: NSBundle.mainBundle())
        let authcontroller = storyboard.instantiateInitialViewController()
        self.window?.makeKeyAndVisible()
        self.window?.rootViewController?.presentViewController(authcontroller!, animated: animated, completion: { })
    }
    
    func logoutAuth() {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let initial = storyboard.instantiateInitialViewController()
        UIView.transitionWithView(self.window!, duration: 0.8, options: .TransitionFlipFromLeft, animations: {
            self.window?.rootViewController = initial
            self.showAuthFlow(false)
            }, completion: nil)
    }
    
    func customizeAppearance() {
        let border = UIImage().imageWithColor(UIColor (red: 0.0, green: 0.0, blue: 0.0, alpha: 0.1))
        let tabbarAppearance = UITabBar.appearance()
        tabbarAppearance.shadowImage = border
        tabbarAppearance.backgroundImage = UIImage()
        tabbarAppearance.backgroundColor = UIColor.whiteColor()
        
        let navigationBarAppearance = UINavigationBar.appearance()
        let insets = UIEdgeInsetsMake(0, 0, 5, 0)
        let image = UIImage(named: "icon-Back-Arrow")?.imageWithAlignmentRectInsets(insets)
        navigationBarAppearance.backIndicatorImage = image
        navigationBarAppearance.backIndicatorTransitionMaskImage = image
//        navigationBarAppearance.shadowImage = border
//        navigationBarAppearance.setBackgroundImage(UIImage(), forBarMetrics: .Default)
        navigationBarAppearance.backgroundColor = UIColor.whiteColor()
        navigationBarAppearance.tintColor = UIColor ( red: 0.0392, green: 0.3333, blue: 0.4706, alpha: 1.0 )
        navigationBarAppearance.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: 0.87 ),
            NSFontAttributeName : UIFont(name: "SFUIText-Regular", size: 15)!
        ]
        
        let barButtonAppearance = UIBarButtonItem.appearance()
        barButtonAppearance.setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), forBarMetrics:.Default)
    }
    
// push notification tokens
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        Intercom.setDeviceToken(deviceToken)
        Localytics.setPushToken(deviceToken)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Failed to register for remote notification: \(error.description)")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        Localytics.handleNotification(userInfo)
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        Localytics.handleNotification(notification.userInfo!)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return sharedAuth.lock.handleURL(url, sourceApplication: sourceApplication)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Localytics.dismissCurrentInAppMessage()
        Localytics.closeSession()
        Localytics.upload()
    }
    

    func application(application: UIApplication, performActionForShortcutItem shortcutItem: UIApplicationShortcutItem, completionHandler: (Bool) -> Void) {
        
        // Handle quick actions
        completionHandler(handleQuickAction(shortcutItem))
        
    }
    
    func handleQuickAction(shortcutItem: UIApplicationShortcutItem) -> Bool {
        
        var quickActionHandled = false
        let type = shortcutItem.type.componentsSeparatedByString(".").last!
        if let shortcutType = Shortcut.init(rawValue: type) {
            let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
            let initial = storyboard.instantiateInitialViewController() as? UITabBarController
            self.window?.rootViewController = initial
            switch shortcutType {
            case .openSearch:
                quickSearch = 1
                quickActionHandled = true
            case .openConcierge:
                quickConcierge = 1
                initial?.selectedIndex = 2
                quickActionHandled = true
            }
        }
        return quickActionHandled
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        viewController.viewDidAppear(true)
    }
    
    func application(application: UIApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            if sharedAuth.isLoggedIn() {
                presentVenueForURL(userActivity.webpageURL!)
            }
        }
        return true
    }
    
    func presentVenueForURL(URL: NSURL) {
        var separator = URL.absoluteString.componentsSeparatedByString("/v/")
        separator = separator.last!.componentsSeparatedByString("/")
        let venueID = separator.last
        sharedAPI.getDataForVenue(venueID!, completionHandler: { (value) in
            if value != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    let realm = try! Realm()
                    realm.beginWrite()
                    let venue = realm.create(Venue.self, value: value, update: true)
                    try! realm.commitWrite()
                    let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                    let initial = storyboard.instantiateInitialViewController()
                    self.window?.rootViewController = initial
                    let navigation = self.window?.rootViewController?.childViewControllers.first! as? UINavigationController
                    let controller = navigation?.viewControllers[1] as! HomeViewController
                    controller.performSegueWithIdentifier("showVenueDetailSegue", sender: venue)
                    
//                    UIView.transitionWithView(self.window!, duration: 0.0, options: .TransitionNone, animations: {
//                        self.window?.rootViewController = initial
//                        }, completion: { (finished: Bool) -> () in
//                            let navigation = self.window?.rootViewController?.childViewControllers.first! as? UINavigationController
//                            let controller = navigation?.viewControllers[1] as! HomeViewController
//                            controller.performSegueWithIdentifier("showVenueDetailSegue", sender: venue)
//                    })
                })
            }
        })
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        if sharedAuth.isLoggedIn() {
//            let stack = RealmStack.sharedStack
//            let realm = try! Realm()
//            let regions = realm.objects(Region).filter("lastSeen == false").sorted("counter")
//            let queries = realm.objects(Query).filter("lastSeen == false").sorted("counter")
//            if regions.count == 0 {
//                sharedAPI.importRegions()
//            }
//            else {
//                stack.prepareRegions()
//            }
//            
//            if queries.count == 0 {
//                sharedAPI.importQueries()
//            }
//            else {
//                stack.prepareSliderObjects()
//            }
//
//            sharedAPI.retrieveFeaturedVenues()
  
                NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notification.BGMode, object: nil)
        }
    }
    
    func applicationDidBecomeActive(application: UIApplication) {

        application.registerUserNotificationSettings(
            UIUserNotificationSettings(
                forTypes: [.Alert, .Badge, .Sound],
                categories: nil))
            

  //      application.registerUserNotificationSettings(
  //      UIUserNotificationSettings(
  //      forTypes: [.Alert, .Badge, .Sound],
  //      categories: nil))


        Localytics.openSession()
        Localytics.upload()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

