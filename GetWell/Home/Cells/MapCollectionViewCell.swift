//
//  MapCollectionViewCell.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import UIKit

class MapCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var venueNameLabel: UILabel!
    @IBOutlet weak var venueInfoLabel: UILabel!
    @IBOutlet weak var venueDistanceLabel: UILabel!

    @IBOutlet weak var imageRate1: UIImageView!
    @IBOutlet weak var imageRate2: UIImageView!
    @IBOutlet weak var imageRate3: UIImageView!
    @IBOutlet weak var imageRate4: UIImageView!
    @IBOutlet weak var imageRate5: UIImageView!
    
    let sharedUI = UIManager.sharedManager
    let sharedLocation = LocationManager.sharedManager
    
    var indexPath: NSIndexPath?
    var color: UIColor?
    
    var venue: Venue! {
        didSet { update() }
    }
    
    func update() {
        
        color = sharedUI.colorForCategory(venue.category.lowercaseString)
        venueNameLabel.text = venue.name
        venueInfoLabel.text = venue.subcategory
        venueNameLabel.textColor = color
        
        if venue.sort > 0 {
            venueDistanceLabel.text = "\(sharedUI.numberFormatter.stringFromNumber(venue.sort)!) miles"
        }
        else {
            if sharedLocation.status == .AuthorizedWhenInUse {
                venueDistanceLabel.text = "\(sharedUI.numberFormatter.stringFromNumber(sharedLocation.returnDistance(venue.latitude, lng: venue.longitude))!) miles"
            }
        }
        
        displayRate(venue.rate)
        imageRate1.tintColor = sharedUI.colorRate
        imageRate2.tintColor = sharedUI.colorRate
        imageRate3.tintColor = sharedUI.colorRate
        imageRate4.tintColor = sharedUI.colorRate
        imageRate5.tintColor = sharedUI.colorRate
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