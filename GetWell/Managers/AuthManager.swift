//
//  AuthManager.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import UIKit
import Lock
import Intercom
import Alamofire
import Localytics
import LockFacebook
import SimpleKeychain
import PermissionScope

class AuthManager: NSObject {
    
    static let sharedManager = AuthManager()
    let lock: A0Lock!
    let keychain: A0SimpleKeychain!
    let permission = PermissionScope()
    let sharedUI = UIManager.sharedManager
    var permissionRequested = false

    override init() {
        keychain = A0SimpleKeychain(service: "Auth0")
        lock = A0Lock()
        let facebook = A0FacebookAuthenticator.newAuthenticatorWithPermissions(["public_profile", "email"])
        lock.registerAuthenticators([facebook])
    }
    
    func updateAuth0User(user: String, customerID: String) {
        
        let params = [
            "app_metadata":
            ["stripeCustomer" : customerID]
        ]
        
        let token = Constants.Auth.auth0UpdateToken
        let URL = Constants.Auth.auth0UserURL + user.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        
        Alamofire.request(.PATCH, URL, parameters: params, encoding: .JSON, headers: ["Authorization": "Bearer \(token)"])
            .responseJSON { response in
            if response.result.isSuccess {
                self.keychain.deleteEntryForKey("profile")
                let profile = A0UserProfile(dictionary: response.result.value! as! [NSObject : AnyObject])
                self.updateIntercomUser(profile)
                self.keychain.setData(NSKeyedArchiver.archivedDataWithRootObject(profile), forKey: "profile")
            }
        }
    }
    
    func requestPermission() {
        let authorizeColor  = UIColor ( red: 0.0529, green: 0.2613, blue: 0.3944, alpha: 1.0 )
        let unathorizeColor = UIColor ( red: 0.6275, green: 0.1176, blue: 0.1961, alpha: 1.0 )
        let font = UIFont(name: "SFUIText-Regular", size: 14)
        let labelFont = UIFont(name: "SFUIText-Regular", size: 12)
        permission.permissionButtonCornerRadius = 0
        permission.closeButtonTextColor = UIColor.lightGrayColor()
        permission.headerLabel.text = "Good " + sharedUI.currentTime() + "!"
        permission.headerLabel.font = UIFont(name: "SFUIText-Regular", size: 18)
        permission.headerLabel.textColor = authorizeColor
        permission.closeButton.setImage(UIImage(named: "icon-Close"), forState: .Normal)
        permission.closeButton.tintColor = UIColor.blackColor()
        permission.closeOffset = CGSizeMake(10, 5)
        permission.buttonFont = font!
        permission.labelFont = labelFont!
        permission.bodyLabel.font = font
        permission.permissionButtonBorderColor = authorizeColor
        permission.permissionButtonTextColor   = authorizeColor
        permission.authorizedButtonColor       = authorizeColor
        permission.unauthorizedButtonColor     = unathorizeColor
        permission.addPermission(NotificationsPermission(), message: "Turn on notifications? We might need to send you a message from time-to-time.")
        permission.addPermission(LocationWhileInUsePermission(), message: "Turn on location? It's only on when using the app, and it helps find places nearby.")
        permission.show()
        permission.onAuthChange = { (finished, results) in
            for result: PermissionResult in results {
                if result.type == PermissionType.LocationInUse {
                    if result.status == PermissionStatus.Authorized {
                        LocationManager.sharedManager.startManager()
                    }
                }
            }
        }
    }
    
    func userProfile(completion:(profile: A0UserProfile!) -> Void) {
        if self.keychain.hasValueForKey("profile") {
            let data: NSData! = keychain.dataForKey("profile")
            let profile: A0UserProfile = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! A0UserProfile
            self.updateIntercomUser(profile)
            completion(profile: profile)
        }
    }
    
    func updateIntercomUser(profile: A0UserProfile!) {
        Intercom.registerUserWithEmail(profile.email!)
        let attributes = [
            "id"    : profile.userId,
            "name"  : profile.name,
            "email" : profile.email!
        ]
        Intercom.updateUserWithAttributes(attributes)
        Localytics.tagCustomerLoggedIn(LLCustomer.init(block: { (builder: LLCustomerBuilder) in
            builder.customerId   = profile.userId
            builder.fullName     = profile.name
            builder.emailAddress = profile.email
        }),
                                       methodName: "Native-iOS",
                                       attributes: [:])
    }
    
    func isLoggedIn() -> Bool {
        if self.keychain.hasValueForKey("profile") {
            return true
        }
        else {
            return false
        }
    }
    
}