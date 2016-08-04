//
//  RegionTableViewCell.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import UIKit
import SDWebImage

class RegionTableViewCell: UITableViewCell {
    
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    let sharedUI = UIManager.sharedManager
    let sharedStack = RealmStack.sharedStack
    
    var imgChatData : NSData!
    var imgFavoData : NSData!

    var index: Int! {
        didSet { checkIndex() }
    }
    
    var region: Region! {
        didSet {
            update()
        }
    }
    
    func checkIndex() {
        if index == 0 {
            titleLabel.text       = sharedUI.conciergeTitle
//            photoImageView!.image = sharedUI.imageHomeConcierge
            descriptionLabel.text = sharedUI.conciergeDesc
            if imgChatData != nil {
                self.photoImageView!.image = UIImage(data: imgChatData)
            } else {
                let url = NSURL(string: Constants.GWAPI.chatURL)
                NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
                    if data != nil && error == nil {
                        let image : UIImage = UIImage(data: data!)!;
                        self.imgChatData = data
                        dispatch_async(dispatch_get_main_queue(), {
                            self.photoImageView!.image = image
                        })
                    }
                    
                }).resume()
            }
            
        }
        if index == 2 {
            
            let count = sharedStack.favoriteVenues()!.count + sharedStack.featuredVenues()!.count
            print(count)
            titleLabel.text       = sharedUI.favoriteTitle
//            photoImageView!.image = sharedUI.imageHomeFavorite
            descriptionLabel.text = "\(count) Places to Eat, Move, and Heal"
            
            if imgFavoData != nil {
                self.photoImageView!.image = UIImage(data: imgFavoData)
            } else {
                let url = NSURL(string: Constants.GWAPI.faveURL)
                NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) in
                    if data != nil && error == nil {
                        let image : UIImage = UIImage(data: data!)!;
                        self.imgFavoData = data
                        dispatch_async(dispatch_get_main_queue(), {
                            self.photoImageView!.image = image
                        })
                    }
                    
                }).resume()
            }
            
        }
    }
    
    func update() {
        let placeholder = sharedUI.imagePlaceholder
        if region.image != "" {
            let URL = NSMutableString(string: region.image)
            URL.insertString(sharedUI.ratio, atIndex: 50)
            SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: region.image), options: .RetryFailed, progress: { (receivedSize: Int, expectedSize: Int) in
                }, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, finished: Bool, url: NSURL!) in
                    if error != nil {
                        print("Error: \(error.userInfo)")
                    }
                    if image != nil {
                        self.photoImageView.image = image
                    }
                    else {
                        UIView.transitionWithView(self.photoImageView
                            ,duration: 0.2
                            ,options: UIViewAnimationOptions.TransitionCrossDissolve
                            ,animations: {
                                self.photoImageView.image = image
                            }
                            ,completion: {(finished) in
                        })
                    }
            })
        }
        else {
            self.photoImageView.image = placeholder
        }
        titleLabel.text = region!.name
        descriptionLabel.text = "\(region!.places) Places to Eat, Move, and Heal"
    }
    
}