//
//  SearchTableViewCell.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import UIKit

class SearchTableViewCell: UITableViewCell {

    let sharedUI = UIManager.sharedManager
    let sharedLocation = LocationManager.sharedManager
    
    var color: UIColor?
    
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var venueInfoLabel: UILabel!
    @IBOutlet weak var venueDistanceLabel: UILabel!
    
    @IBOutlet weak var imageRate1: UIImageView!
    @IBOutlet weak var imageRate2: UIImageView!
    @IBOutlet weak var imageRate3: UIImageView!
    @IBOutlet weak var imageRate4: UIImageView!
    @IBOutlet weak var imageRate5: UIImageView!
    
    
    var search: Search! {
        didSet {
            updateSearch()
        }
    }
    
    var venue: Venue! {
        didSet {
            update()
        }
    }
    
    func updateSearch() {
        venueNameLabel.text      = search.term
        venueNameLabel.font      = UIFont(name: "SFUIText-Medium", size: 16)!
        venueNameLabel.textColor = UIColor (red: 0.0, green: 0.2667, blue: 0.4, alpha: 1.0)
        venueInfoLabel.text      = "\(search.count) Places"
        venueDistanceLabel.text = ""
        hiddenRate(true)
    }
    
    func update() {
        
        color = sharedUI.colorForCategory(venue.category.lowercaseString)
        venueNameLabel.font          = UIFont(name: "SFUIText-Light", size: 20)!
        venueNameLabel.textColor     = color
        venueNameLabel.text = venue.name
        venueInfoLabel.text = venue.subcategory
        
        if venue.sort > 0 {
            venueDistanceLabel.text = "\(sharedUI.numberFormatter.stringFromNumber(venue.sort)!) miles"
        }
        
        imageRate1.tintColor = sharedUI.colorRate
        imageRate2.tintColor = sharedUI.colorRate
        imageRate3.tintColor = sharedUI.colorRate
        imageRate4.tintColor = sharedUI.colorRate
        imageRate5.tintColor = sharedUI.colorRate
        hiddenRate(false)
        displayRate(venue.rate)
    }

    
    func hiddenRate(value: Bool) {
        imageRate1.hidden = value
        imageRate2.hidden = value
        imageRate3.hidden = value
        imageRate4.hidden = value
        imageRate5.hidden = value
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
