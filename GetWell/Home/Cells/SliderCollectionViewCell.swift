//
//  SliderCollectionViewCell.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import UIKit
import SDWebImage

class SliderCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var headImage:        UIImageView!
    @IBOutlet weak var titleLabel:       UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var locationLabel:    UILabel!
    
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
    
    let sharedUI = UIManager.sharedManager    
    var color: UIColor?
    var venue: Venue! {
        didSet { update() }
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
            URL = NSMutableString(string: sharedUI.categoryImageURL(venue.category.lowercaseString))
        }

        URL!.insertString(sharedUI.ratio, atIndex: sharedUI.index)
        headImage.sd_setImageWithURL(NSURL(string: URL! as String)!
            ,placeholderImage: UIImage().imageWithColor(UIColor ( red: 0.902, green: 0.902, blue: 0.902, alpha: 1.0 ))
            ,completed: { ( image: UIImage!, error: NSError!, type: SDImageCacheType, url: NSURL!) in
                UIView.transitionWithView(self.headImage
                    ,duration: 0.0
                    ,options: UIViewAnimationOptions.TransitionCrossDissolve
                    ,animations: {
                        self.headImage.image = image
                    }
                    ,completion: {(finished) in
                })
        })

        titleLabel.textColor  = color
        titleLabel.text       = venue.name
        descriptionLabel.text = venue.subcategory
        
        let type = venue.category.lowercaseString
        if type == "online" {
            locationLabel.text = sharedUI.parseURL(venue.website)
            hiddenCost(true)
        }
        else {
            locationLabel.text = "\(venue.neighborhood), \(venue.city), \(venue.state)"
            hiddenCost(false)
        }
        
        displayRate(venue.rate)
        displayCost(venue.cost)
        
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
    
    func hiddenCost(value: Bool) {
        imageCost1.hidden = value
        imageCost2.hidden = value
        imageCost3.hidden = value
        imageCost4.hidden = value
        imageCost5.hidden = value
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
}
