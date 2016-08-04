//
//  SignViewController.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import UIKit
import Lock
import Localytics

class SignViewController: UIViewController {
    
    let sharedAuth    = AuthManager.sharedManager
    let sharedStack   = RealmStack.sharedStack
    let appDelegate   = UIApplication.sharedApplication().delegate as! AppDelegate
    
    var action: String?
    @IBOutlet weak var signTitleLabel: UILabel!
    @IBOutlet weak var signInfoLabel: UILabel!
    @IBOutlet weak var buttonFacebook: UIButton!
    @IBOutlet weak var buttonGoogle: UIButton!
    @IBOutlet weak var legalLabel: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        update()
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        navigationController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : UIColor (red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0),
            NSFontAttributeName : UIFont(name: "SFUIText-Regular", size: 15)!
        ]
        let gesture = UITapGestureRecognizer(target: self, action: #selector(linkTapped))
        gesture.numberOfTapsRequired = 1
        legalLabel.addGestureRecognizer(gesture)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillAppear(animated)
    }
    
    func linkTapped(sender: UITapGestureRecognizer) {
        openLegalPage()
    }
    
    func openLegalPage() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewControllerWithIdentifier("webviewController") as! WebViewController
        let navigation = UINavigationController(rootViewController: controller)
        let button = UIBarButtonItem(image: UIImage(named: "icon-Close"), style: .Plain, target: self, action: #selector(dismissController))
        controller.navigationItem.title = "Get Well Legal"
        controller.navigationItem.rightBarButtonItem = button
        controller.URL = NSURL(string: Constants.GWAPI.legalURL)
        self.presentViewController(navigation, animated: true, completion: nil)
    }
    
    func dismissController() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func buttonPressed(sender: AnyObject) {
        let connectionName: String
        if sender as! NSObject == self.buttonFacebook {
            connectionName = "facebook"
        }
        else {
            connectionName = "google-oauth2"
        }
        sharedAuth.lock.identityProviderAuthenticator().authenticateWithConnectionName(connectionName,
                                                                                       parameters: nil,
                                                                                       success: self.successCallback(),
                                                                                       failure: self.errorCallback())
    }
    
    private func successCallback() -> (A0UserProfile, A0Token) -> () { return { (profile, token) -> Void in
        
//        print("userId:       \(profile.userId)",
//              "name:         \(profile.name)",
//              "email:        \(profile.picture)",
//              "nickname:     \(profile.nickname)",
//              "picture:      \(profile.picture)",
//              "createdAt:    \(profile.createdAt)",
//              "appMetadata:  \(profile.appMetadata)",
//              "userMetadata: \(profile.userMetadata)",
//              "identities:   \(profile.identities)",
//              "extraInfo:    \(profile.extraInfo)", separator:"\n", terminator: "\n\n")
//        dispatch_async(dispatch_get_main_queue(),{
//            self.indicatorView.startAnimating()
//        })
        
        self.sharedAuth.updateIntercomUser(profile)
        self.sharedAuth.keychain.setString(token.idToken, forKey: "id_token")
        
        if let refreshToken = token.refreshToken {
            self.sharedAuth.keychain.setString(refreshToken, forKey: "refresh_token")
        }
        self.sharedAuth.keychain.setData(NSKeyedArchiver.archivedDataWithRootObject(profile), forKey: "profile")
        
        self.appDelegate.customizeAppearance()
        
        self.dismissViewControllerAnimated(true, completion: {
            if !self.sharedAuth.permissionRequested {
                self.sharedAuth.requestPermission()
                self.sharedAuth.permissionRequested = true
            }
        })
    }}

    func update() {
        if action! == "signin" {
            Localytics.tagScreen("SignIn")
            self.title = "Log In"
            signTitleLabel.text = "Welcome Back"
            signInfoLabel.text  = "It’s good to see you again! Select either Facebook or Google to log in."
            buttonFacebook.setTitle("Log in with Facebook", forState: .Normal)
            buttonGoogle.setTitle("Log in with Google", forState: .Normal)
        }
        if action! == "signup" {
            Localytics.tagScreen("SignUp")
            self.title = "Sign Up"
            signTitleLabel.text = "Get Started"
            signInfoLabel.text  = "We're excited to meet you. Select either Facebook or Google to sign up."
            buttonFacebook.setTitle("Sign up with Facebook", forState: .Normal)
            buttonGoogle.setTitle("Sign up with Google", forState: .Normal)
        }
    }
    
    private func errorCallback() -> NSError -> () {
        return { error in
            let alert = UIAlertController(title: "Whoops.", message: "That didn't work. Please try again.", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            print("Failed with error \(error)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
