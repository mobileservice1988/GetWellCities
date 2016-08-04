//
//  VenueTableViewCell.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import UIKit
import SDWebImage
import RealmSwift

protocol VenueCellDelegate {
    func cellFavoriteButtonTapped(cell: VenueTableViewCell)
}

class VenueTableViewCell: UITableViewCell {
    
    var delegate: VenueCellDelegate?
    @IBOutlet weak var venueHeadImage:     UIImageView!
    @IBOutlet weak var venueNameLabel:     UILabel!
    @IBOutlet weak var venueInfoLabel:     UILabel!
    @IBOutlet weak var venueHoursLabel:    UILabel!
    @IBOutlet weak var venueDistanceLabel: UILabel!
    @IBOutlet weak var venueLocationLabel: UILabel!
    
    @IBOutlet weak var imageRate1: UIImageView!
    @IBOutlet weak var imageRate2: UIImageView!
    @IBOutlet weak var imageRate3: UIImageView!
    @IBOutlet weak var imageRate4: UIImageView!
    @IBOutlet weak var imageRate5: UIImageView!
    
    @IBOutlet weak var imageCost1: UIImageView!
    @IBOutlet weak var imageCost2: UIImageView!
    @IBOutlet weak var imageCost3: UIImageView!
    @IBOutlet weak var imageCost4: UIImageView!
    @IBOutlet weak var imageCost5: UIImageView!
    
    @IBOutlet weak var certifiedView:          UIView!
    @IBOutlet weak var certifiedSeparator:     UIView!
    @IBOutlet weak var certifiedLabel:         UILabel!
    @IBOutlet weak var certifiedImage:         UIImageView!
    @IBOutlet weak var certifiedCategoryImage: UIImageView!
    @IBOutlet weak var certifiedViewWidth:     NSLayoutConstraint!
    @IBOutlet weak var loadIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBAction func favoriteButtonPressed(sender: AnyObject) {
        if let delegate = delegate {
            delegate.cellFavoriteButtonTapped(self)
        }
    }
    
    var color: UIColor?
    let realm = try! Realm()
    let sharedUI = UIManager.sharedManager
    let sharedLocation = LocationManager.sharedManager
    
    var venue: Venue! {
        didSet {
            update()
        }
    }
    
    func update() {

        var category = venue.category.lowercaseString
        if category == "online" || category == "event" { category = venue.subcategory.lowercaseString }
        color = sharedUI.colorForCategory(category)
        
        var URL: NSMutableString?
        if venue.poster != "" {
            URL = NSMutableString(string: venue.poster)
        }
        else {
            URL = NSMutableString(string: sharedUI.categoryImageURL(category))
        }
        
        URL!.insertString(sharedUI.ratio, atIndex: sharedUI.index)
        venueHeadImage.sd_setImageWithURL(NSURL(string: URL! as String)!
            ,placeholderImage: UIImage().imageWithColor(UIColor ( red: 0.902, green: 0.902, blue: 0.902, alpha: 1.0 ))
            ,completed: { ( image: UIImage!, error: NSError!, type: SDImageCacheType, url: NSURL!) in
                UIView.transitionWithView(self.venueHeadImage
                    ,duration: 0.2
                    ,options: .TransitionCrossDissolve
                    ,animations: {
                        self.venueHeadImage.image = image
                    }
                    ,completion: {(finished) in
                })
        })
        
        if let existingVenue = realm.objectForPrimaryKey(Venue.self, key: venue.id) {
            if existingVenue.favorite {
                self.favoriteButton.selected = true
                favoriteButton.tintColor = color
            }
            else {
                self.favoriteButton.selected = false
                favoriteButton.tintColor = UIColor.whiteColor()
            }
        }
        else {
            favoriteButton.selected = false
            favoriteButton.tintColor = UIColor.whiteColor()
        }
        
        if !venue.certified {
            let bool = true
            certifiedViewWidth.constant = 58
            certifiedLabel.hidden       = bool
            certifiedImage.hidden       = bool
            certifiedSeparator.hidden   = bool
        }
        else {
            let bool = false
            certifiedViewWidth.constant = 200
            certifiedLabel.hidden       = bool
            certifiedImage.hidden       = bool
            certifiedSeparator.hidden   = bool
        }
        
        venueNameLabel.text = venue.name
        venueInfoLabel.text = venue.subcategory
        venueLocationLabel.text = "\(venue.neighborhood), \(venue.city), \(venue.state)"
        
        if venue.sort > 0 {
            venueDistanceLabel.text = "\(sharedUI.numberFormatter.stringFromNumber(venue.sort)!) miles"
        }
        else {
            if sharedLocation.status == .AuthorizedWhenInUse {
                venueDistanceLabel.text =  "\(sharedUI.numberFormatter.stringFromNumber(sharedLocation.returnDistance(venue.latitude, lng: venue.longitude))!) miles"
            }
        }
    
        venueNameLabel.textColor         = color
        certifiedCategoryImage.image     = sharedUI.imageForCategory(venue.category.lowercaseString)
        certifiedCategoryImage.tintColor = UIColor.whiteColor()
        
        displayRate(venue.rate)
        displayCost(venue.cost)
        
        let type = venue.category.lowercaseString
        if type == "online" {
            let website = sharedUI.parseURL(venue.website)
            if website != "" { venueDistanceLabel.text = website }
            venueLocationLabel.text = ""
            imageCost1.hidden = true
            imageCost2.hidden = true
            imageCost3.hidden = true
            imageCost4.hidden = true
            imageCost5.hidden = true
        }
        else {
            imageCost1.hidden = false
            imageCost2.hidden = false
            imageCost3.hidden = false
            imageCost4.hidden = false
            imageCost5.hidden = false
        }
        
        imageRate1.tintColor = sharedUI.colorRate
        imageRate2.tintColor = sharedUI.colorRate
        imageRate3.tintColor = sharedUI.colorRate
        imageRate4.tintColor = sharedUI.colorRate
        imageRate5.tintColor = sharedUI.colorRate
        
        imageCost1.tintColor = sharedUI.colorCost
        imageCost2.tintColor = sharedUI.colorCost
        imageCost3.tintColor = sharedUI.colorCost
        imageCost4.tintColor = sharedUI.colorCost
        imageCost5.tintColor = sharedUI.colorCost
    }
    
    func displayCost(cost: Int) {
        let amount = sharedUI.cost(cost)
        switch (amount) {
        case .Cost0():
            imageCost1.image = sharedUI.imageCostEmpty
            imageCost2.image = sharedUI.imageCostEmpty
            imageCost3.image = sharedUI.imageCostEmpty
            imageCost4.image = sharedUI.imageCostEmpty
            imageCost5.image = sharedUI.imageCostEmpty
        case .Cost1():
            imageCost1.image = sharedUI.imageCostFull
            imageCost2.image = sharedUI.imageCostEmpty
            imageCost3.image = sharedUI.imageCostEmpty
            imageCost4.image = sharedUI.imageCostEmpty
            imageCost5.image = sharedUI.imageCostEmpty
        case .Cost2():
            imageCost1.image = sharedUI.imageCostFull
            imageCost2.image = sharedUI.imageCostFull
            imageCost3.image = sharedUI.imageCostEmpty
            imageCost4.image = sharedUI.imageCostEmpty
            imageCost5.image = sharedUI.imageCostEmpty
        case .Cost3():
            imageCost1.image = sharedUI.imageCostFull
            imageCost2.image = sharedUI.imageCostFull
            imageCost3.image = sharedUI.imageCostFull
            imageCost4.image = sharedUI.imageCostEmpty
            imageCost5.image = sharedUI.imageCostEmpty
        case .Cost4():
            imageCost1.image = sharedUI.imageCostFull
            imageCost2.image = sharedUI.imageCostFull
            imageCost3.image = sharedUI.imageCostFull
            imageCost4.image = sharedUI.imageCostFull
            imageCost5.image = sharedUI.imageCostEmpty
        case .Cost5():
            imageCost1.image = sharedUI.imageCostFull
            imageCost2.image = sharedUI.imageCostFull
            imageCost3.image = sharedUI.imageCostFull
            imageCost4.image = sharedUI.imageCostFull
            imageCost5.image = sharedUI.imageCostFull
        }
    }
    
    func displayRate(rate: Double) {
        let rating = sharedUI.rate(rate)
        switch (rating) {
        case .Rate00():
            imageRate1.image = sharedUI.imageRateEmpty
            imageRate2.image = sharedUI.imageRateEmpty
            imageRate3.image = sharedUI.imageRateEmpty
            imageRate4.image = sharedUI.imageRateEmpty
            imageRate5.image = sharedUI.imageRateEmpty
        case .Rate05():
            imageRate1.image = sharedUI.imageRateHalf
            imageRate2.image = sharedUI.imageRateEmpty
            imageRate3.image = sharedUI.imageRateEmpty
            imageRate4.image = sharedUI.imageRateEmpty
            imageRate5.image = sharedUI.imageRateEmpty
        case .Rate10():
            imageRate1.image = sharedUI.imageRateFull
            imageRate2.image = sharedUI.imageRateEmpty
            imageRate3.image = sharedUI.imageRateEmpty
            imageRate4.image = sharedUI.imageRateEmpty
            imageRate5.image = sharedUI.imageRateEmpty
        case .Rate15():
            imageRate1.image = sharedUI.imageRateFull
            imageRate2.image = sharedUI.imageRateHalf
            imageRate3.image = sharedUI.imageRateEmpty
            imageRate4.image = sharedUI.imageRateEmpty
            imageRate5.image = sharedUI.imageRateEmpty
        case .Rate20():
            imageRate1.image = sharedUI.imageRateFull
            imageRate2.image = sharedUI.imageRateFull
            imageRate3.image = sharedUI.imageRateEmpty
            imageRate4.image = sharedUI.imageRateEmpty
            imageRate5.image = sharedUI.imageRateEmpty
        case .Rate25():
            imageRate1.image = sharedUI.imageRateFull
            imageRate2.image = sharedUI.imageRateFull
            imageRate3.image = sharedUI.imageRateHalf
            imageRate4.image = sharedUI.imageRateEmpty
            imageRate5.image = sharedUI.imageRateEmpty
        case .Rate30():
            imageRate1.image = sharedUI.imageRateFull
            imageRate2.image = sharedUI.imageRateFull
            imageRate3.image = sharedUI.imageRateFull
            imageRate4.image = sharedUI.imageRateEmpty
            imageRate5.image = sharedUI.imageRateEmpty
        case .Rate35():
            imageRate1.image = sharedUI.imageRateFull
            imageRate2.image = sharedUI.imageRateFull
            imageRate3.image = sharedUI.imageRateFull
            imageRate4.image = sharedUI.imageRateHalf
            imageRate5.image = sharedUI.imageRateEmpty
        case .Rate40():
            imageRate1.image = sharedUI.imageRateFull
            imageRate2.image = sharedUI.imageRateFull
            imageRate3.image = sharedUI.imageRateFull
            imageRate4.image = sharedUI.imageRateFull
            imageRate5.image = sharedUI.imageRateEmpty
        case .Rate45():
            imageRate1.image = sharedUI.imageRateFull
            imageRate2.image = sharedUI.imageRateFull
            imageRate3.image = sharedUI.imageRateFull
            imageRate4.image = sharedUI.imageRateFull
            imageRate5.image = sharedUI.imageRateHalf
        case .Rate50():
            imageRate1.image = sharedUI.imageRateFull
            imageRate2.image = sharedUI.imageRateFull
            imageRate3.image = sharedUI.imageRateFull
            imageRate4.image = sharedUI.imageRateFull
            imageRate5.image = sharedUI.imageRateFull
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
