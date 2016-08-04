//
//  SliderTableViewCell.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import UIKit

struct SlideObject {
    var query : Query!
    var objects : [Venue]!
}

class SliderTableViewCell: UITableViewCell {
    
    @IBOutlet weak var headImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    
    let manager = UIManager.sharedManager
    let sharedLocation = LocationManager.sharedManager
    
    var slideObject: SlideObject! {
        didSet { update() }
    }
    
    func update() {
        let city = sharedLocation.city.capitalizedString
        var description = slideObject.query.name
        if description.containsString("[city]") {
            description = description.stringByReplacingOccurrencesOfString("[city]", withString: city)
        }
        
        descriptionLabel.text = ("\(slideObject.objects.count) " + description).capitalizedString
        
        let cat = slideObject.query.category.lowercaseString
        
        if cat == "eat" {
            headImage.image            = manager.iconSlideEat
            titleLabel.textColor       = manager.colorEat
            descriptionLabel.textColor = manager.colorEat
            titleLabel.text            = "Places to Eat"
        }
        if cat == "move" {
            headImage.image            = manager.iconSlideMove
            titleLabel.textColor       = manager.colorMove
            descriptionLabel.textColor = manager.colorMove
            titleLabel.text            = "Places to Move"
        }
        if cat == "heal" {
            headImage.image            = manager.iconSlideHeal
            titleLabel.textColor       = manager.colorHeal
            descriptionLabel.textColor = manager.colorHeal
            titleLabel.text            = "Places to Heal"
        }
        if cat == "event" {
            headImage.image            = manager.iconSlideEvent
            titleLabel.textColor       = manager.colorEvent
            descriptionLabel.textColor = manager.colorEvent
            titleLabel.text            = "Events"
        }
        if cat == "online" {
            headImage.image            = manager.iconSlideOnline
            titleLabel.textColor       = manager.colorOnline
            descriptionLabel.textColor = manager.colorOnline
            titleLabel.text            = "On the Web"
        }
        
    }
    
}

extension SliderTableViewCell {
    
    func setCollectionViewDataSourceDelegate<D: protocol<UICollectionViewDataSource, UICollectionViewDelegate>>(dataSourceDelegate: D, forRow row: Int) {
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.setContentOffset(collectionView.contentOffset, animated:false) // Stops collection view if it was scrolling.
        collectionView.reloadData()
    }
    var collectionViewOffset: CGFloat {
        set {
            collectionView.contentOffset.x = newValue
        }
        get {
            return collectionView.contentOffset.x
        }
    }
}