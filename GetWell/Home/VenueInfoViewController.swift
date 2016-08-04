//
//  VenueInfoViewController.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import UIKit
import Localytics

class VenueInfoViewController: UIViewController {
    
    @IBOutlet weak var venueCuisineView: UIView!
    @IBOutlet weak var venueCuisineTitleLabel: UILabel!
    @IBOutlet weak var venueCuisineContentLabel: UILabel!
    @IBOutlet weak var venueCuisineImageView: UIImageView!

    @IBOutlet weak var venueNutritionView: UIView!
    @IBOutlet weak var venueNutritionTitleLabel: UILabel!
    @IBOutlet weak var venueNutritionContentLabel: UILabel!
    @IBOutlet weak var venueNutritionImageView: UIImageView!
    
    @IBOutlet weak var venueAlcoholView: UIView!
    @IBOutlet weak var venueAlcoholTitleLabel: UILabel!
    @IBOutlet weak var venueAlcoholContentLabel: UILabel!
    @IBOutlet weak var venueAlcoholImageView: UIImageView!
    
    @IBOutlet weak var venueAttireView: UIView!
    @IBOutlet weak var venueAttireTitleLabel: UILabel!
    @IBOutlet weak var venueAttireContentLabel: UILabel!
    @IBOutlet weak var venueAttireImageView: UIImageView!
    
    @IBOutlet weak var venueGoodForView: UIView!
    @IBOutlet weak var venueGoodForTitleLabel: UILabel!
    @IBOutlet weak var venueGoodForContentLabel: UILabel!
    @IBOutlet weak var venueGoodForImageView: UIImageView!

    @IBOutlet weak var venueMenuView: UIView!
    @IBOutlet weak var venueMenuTitleLabel: UILabel!
    @IBOutlet weak var venueMenuContentLabel: UILabel!
    @IBOutlet weak var venueMenuImageView: UIImageView!
    
    @IBOutlet weak var venuePaymentView: UIView!
    @IBOutlet weak var venuePaymentTitleLabel: UILabel!
    @IBOutlet weak var venuePaymentContentLabel: UILabel!
    @IBOutlet weak var venuePaymentImageView: UIImageView!
    
    @IBOutlet weak var venueParkingView: UIView!
    @IBOutlet weak var venueParkingTitleLabel: UILabel!
    @IBOutlet weak var venueParkingContentLabel: UILabel!
    @IBOutlet weak var venueParkingImageView: UIImageView!
    
    @IBOutlet weak var venueTransitView: UIView!
    @IBOutlet weak var venueTransitTitleLabel: UILabel!
    @IBOutlet weak var venueTransitContentLabel: UILabel!
    @IBOutlet weak var venueTransitImageVIew: UIImageView!
    
    @IBOutlet weak var venueAmenitiesView: UIView!
    @IBOutlet weak var venueAmenitiesTitleLabel: UILabel!
    @IBOutlet weak var venueAmenitiesImageView: UIImageView!
    @IBOutlet weak var venueAmenitiesContentLabel: UILabel!
    
    @IBOutlet weak var venueWorkoutView: UIView!
    @IBOutlet weak var venueWorkoutTitleLabel: UILabel!
    @IBOutlet weak var venueWorkoutContentLabel: UILabel!
    @IBOutlet weak var venueWorkoutImageView: UIImageView!
    
    @IBOutlet weak var venueOutdoorView: UIView!
    @IBOutlet weak var venueOutdoorTitleLabel: UILabel!
    @IBOutlet weak var venueOutdoorContentLabel: UILabel!
    @IBOutlet weak var venueOutdoorImageView: UIImageView!
    
    @IBOutlet weak var venuePeopleView: UIView!
    @IBOutlet weak var venuePeopleTitleLabel: UILabel!
    @IBOutlet weak var venuePeopleContentLabel: UILabel!
    @IBOutlet weak var venuePeopleImageView: UIImageView!
    
    @IBOutlet weak var venueProductView: UIView!
    @IBOutlet weak var venueProductTitleLabel: UILabel!
    @IBOutlet weak var venueProductContentLabel: UILabel!
    @IBOutlet weak var venueProductImageView: UIImageView!
    
    @IBOutlet weak var venueHealingView: UIView!
    @IBOutlet weak var venueHealingTitleLabel: UILabel!
    @IBOutlet weak var venueHealingContentLabel: UILabel!
    @IBOutlet weak var venueHealingImageView: UIImageView!
    
    @IBOutlet weak var venueEventTypeView: UIView!
    @IBOutlet weak var venueEventTypeTitleLabel: UILabel!
    @IBOutlet weak var venueEventTypeContentLabel: UILabel!
    @IBOutlet weak var venueEventTypeImageView: UIImageView!
    
    @IBOutlet weak var venueOnlineContentView: UIView!
    @IBOutlet weak var venueOnlineContentTitleLabel: UILabel!
    @IBOutlet weak var venueOnlineContentContentLabel: UILabel!
    @IBOutlet weak var venueOnlineContentImageView: UIImageView!
    
    @IBOutlet weak var venueHoursView: UIView!
    @IBOutlet weak var venueHoursTitleLabel: UILabel!
    @IBOutlet weak var venueHoursImageView: UIImageView!
    @IBOutlet weak var venueLinkViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var venueDayLabel0: UILabel!
    @IBOutlet weak var venueDayLabel1: UILabel!
    @IBOutlet weak var venueDayLabel2: UILabel!
    @IBOutlet weak var venueDayLabel3: UILabel!
    @IBOutlet weak var venueDayLabel4: UILabel!
    @IBOutlet weak var venueDayLabel5: UILabel!
    @IBOutlet weak var venueDayLabel6: UILabel!
    
    @IBOutlet weak var venueHourLabel0: UILabel!
    @IBOutlet weak var venueHourLabel1: UILabel!
    @IBOutlet weak var venueHourLabel2: UILabel!
    @IBOutlet weak var venueHourLabel3: UILabel!
    @IBOutlet weak var venueHourLabel4: UILabel!
    @IBOutlet weak var venueHourLabel5: UILabel!
    @IBOutlet weak var venueHourLabel6: UILabel!
    
    @IBOutlet weak var venueLinksView: UIView!
    @IBOutlet weak var venueLinksTitleLabel: UILabel!
    @IBOutlet weak var venueLinksImageView: UIImageView!
    
    @IBOutlet weak var venueLink0: UILabel!
    @IBOutlet weak var venueLink1: UILabel!
    @IBOutlet weak var venueLink2: UILabel!
    @IBOutlet weak var venueLink3: UILabel!
    @IBOutlet weak var venueLink4: UILabel!
    @IBOutlet weak var venueLink5: UILabel!
    
    var venue: Venue!
    let lineHeight: CGFloat = 1.3
    var color : UIColor?
    let sharedUI       = UIManager.sharedManager
    
    override func viewDidLoad() {
        
        update()
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Localytics.tagScreen("PlaceInfo")
    }
    
    func update() {
        
        title = venue.name
        
        var category = venue.category.lowercaseString
        if category == "online" || category == "event" { category = venue.subcategory.lowercaseString }
        color = sharedUI.colorForCategory(category)
        
        venueLink0.textColor = color
        venueLink1.textColor = color
        venueLink2.textColor = color
        venueLink3.textColor = color
        venueLink4.textColor = color
        venueLink5.textColor = color
        
        if venue.cuisines != "" {
            venueCuisineContentLabel.text = venue.cuisines
            venueCuisineContentLabel.setLineHeight(lineHeight)
        }
        else {
            venueCuisineImageView.removeFromSuperview()
            venueCuisineTitleLabel.removeFromSuperview()
            venueCuisineContentLabel.removeFromSuperview()
        }
        
        if venue.nutrition != "" {
            venueNutritionContentLabel.text = venue.nutrition
            venueNutritionContentLabel.setLineHeight(lineHeight)
        }
        else {
            venueNutritionImageView.removeFromSuperview()
            venueNutritionTitleLabel.removeFromSuperview()
            venueNutritionContentLabel.removeFromSuperview()
        }
        
        if venue.goodFor != "" {
            venueGoodForContentLabel.text = venue.goodFor
            venueGoodForContentLabel.setLineHeight(lineHeight)
        }
        else {
            venueGoodForImageView.removeFromSuperview()
            venueGoodForTitleLabel.removeFromSuperview()
            venueGoodForContentLabel.removeFromSuperview()
        }
        
        if venue.menus != "" {
            venueMenuContentLabel.text = venue.menus
            venueMenuContentLabel.setLineHeight(lineHeight)
        }
        else {
            venueMenuImageView.removeFromSuperview()
            venueMenuTitleLabel.removeFromSuperview()
            venueMenuContentLabel.removeFromSuperview()
        }
        
        if venue.alcohol != "" {
            venueAlcoholContentLabel.text = venue.alcohol
            venueAlcoholContentLabel.setLineHeight(lineHeight)
        }
        else {
            venueAlcoholImageView.removeFromSuperview()
            venueAlcoholTitleLabel.removeFromSuperview()
            venueAlcoholContentLabel.removeFromSuperview()
        }
        
        if venue.attire != "" {
            venueAttireContentLabel.text = venue.attire
            venueAttireContentLabel.setLineHeight(lineHeight)
        }
        else {
            venueAttireImageView.removeFromSuperview()
            venueAttireTitleLabel.removeFromSuperview()
            venueAttireContentLabel.removeFromSuperview()
        }
        
        if venue.workouts != "" {
            venueWorkoutContentLabel.text = venue.workouts
            venueWorkoutContentLabel.setLineHeight(lineHeight)
        }
        else {
            venueWorkoutImageView.removeFromSuperview()
            venueWorkoutTitleLabel.removeFromSuperview()
            venueWorkoutContentLabel.removeFromSuperview()
        }
        
        if venue.amenities != "" {
            venueAmenitiesContentLabel.text = venue.amenities
            venueAmenitiesContentLabel.setLineHeight(lineHeight)
        }
        else {
            venueAmenitiesImageView.removeFromSuperview()
            venueAmenitiesTitleLabel.removeFromSuperview()
            venueAmenitiesContentLabel.removeFromSuperview()
        }
        
        if venue.outdoorRecreation != "" {
            venueOutdoorContentLabel.text = venue.outdoorRecreation
            venueOutdoorContentLabel.setLineHeight(lineHeight)
        }
        else {
            venueOutdoorImageView.removeFromSuperview()
            venueOutdoorTitleLabel.removeFromSuperview()
            venueOutdoorContentLabel.removeFromSuperview()
        }

        if venue.products != "" {
            venueProductContentLabel.text = venue.products
            venueProductContentLabel.setLineHeight(lineHeight)
        }
        else {
            venueProductImageView.removeFromSuperview()
            venueProductTitleLabel.removeFromSuperview()
            venueProductContentLabel.removeFromSuperview()
        }
        
        if venue.healingServices != "" {
            venueHealingContentLabel.text = venue.healingServices
            venueHealingContentLabel.setLineHeight(lineHeight)
        }
        else {
            venueHealingImageView.removeFromSuperview()
            venueHealingTitleLabel.removeFromSuperview()
            venueHealingContentLabel.removeFromSuperview()
        }
        
        if venue.peopleServed != "" {
            venuePeopleContentLabel.text = venue.peopleServed
            venuePeopleContentLabel.setLineHeight(lineHeight)
        }
        else {
            venuePeopleImageView.removeFromSuperview()
            venuePeopleTitleLabel.removeFromSuperview()
            venuePeopleContentLabel.removeFromSuperview()
        }

        if venue.transit != "" {
            venueTransitContentLabel.text = venue.transit
            venueTransitContentLabel.setLineHeight(lineHeight)
        }
        else {
            venueTransitImageVIew.removeFromSuperview()
            venueTransitTitleLabel.removeFromSuperview()
            venueTransitContentLabel.removeFromSuperview()
        }
        
        if venue.parking != "" {
            venueParkingContentLabel.text = venue.parking
            venueParkingContentLabel.setLineHeight(lineHeight)
        }
        else {
            venueParkingImageView.removeFromSuperview()
            venueParkingTitleLabel.removeFromSuperview()
            venueParkingContentLabel.removeFromSuperview()
        }
        
        if venue.payment != "" {
            venuePaymentContentLabel.text = venue.payment
            venuePaymentContentLabel.setLineHeight(lineHeight)
        }
        else {
            venuePaymentImageView.removeFromSuperview()
            venuePaymentTitleLabel.removeFromSuperview()
            venuePaymentContentLabel.removeFromSuperview()
        }
        
        if venue.eventType != "" {
            venueEventTypeContentLabel.text = venue.eventType
            venueEventTypeContentLabel.setLineHeight(lineHeight)
        }
        else {
            venueEventTypeImageView.removeFromSuperview()
            venueEventTypeTitleLabel.removeFromSuperview()
            venueEventTypeContentLabel.removeFromSuperview()
        }
        
        if venue.onlineContent != "" {
            venueOnlineContentContentLabel.text = venue.onlineContent
            venueOnlineContentContentLabel.setLineHeight(lineHeight)
        }
        else {
            venueOnlineContentImageView.removeFromSuperview()
            venueOnlineContentTitleLabel.removeFromSuperview()
            venueOnlineContentContentLabel.removeFromSuperview()
        }

        
        if venue.openingHours != "" {
            
            let openHours = venue.openingHours
            var objects: [String] = []
            openHours.enumerateLines { objects.append($0.line) }
            
            var days: [String]  = []
            var hours: [String] = []
            
            for day in objects {
                let separation = day.componentsSeparatedByString(": ")
                if separation.first != nil {
                    days.append(separation.first!)
                }
                if separation.last != nil {
                    hours.append(separation.last!)
                }
            }
            
            for i in 0...6 {
                if i == 0 {
                    venueDayLabel0.text  = days[i]
                    venueHourLabel0.text = hours[i]
                }
                if i == 1 {
                    venueDayLabel1.text  = days[i]
                    venueHourLabel1.text = hours[i]
                }
                if i == 2 {
                    venueDayLabel2.text  = days[i]
                    venueHourLabel2.text = hours[i]
                }
                if i == 3 {
                    venueDayLabel3.text  = days[i]
                    venueHourLabel3.text = hours[i]
                }
                if i == 4 {
                    venueDayLabel4.text  = days[i]
                    venueHourLabel4.text = hours[i]
                }
                if i == 5 {
                    venueDayLabel5.text  = days[i]
                    venueHourLabel5.text = hours[i]
                }
                if i == 6 {
                    venueDayLabel6.text  = days[i]
                    venueHourLabel6.text = hours[i]
                }
            }
        }
        else {
            
            venueHoursImageView.removeFromSuperview()
            venueHoursTitleLabel.removeFromSuperview()
            venueDayLabel0.removeFromSuperview()
            venueDayLabel1.removeFromSuperview()
            venueDayLabel2.removeFromSuperview()
            venueDayLabel3.removeFromSuperview()
            venueDayLabel4.removeFromSuperview()
            venueDayLabel5.removeFromSuperview()
            venueDayLabel6.removeFromSuperview()
            
            venueHourLabel0.removeFromSuperview()
            venueHourLabel1.removeFromSuperview()
            venueHourLabel2.removeFromSuperview()
            venueHourLabel3.removeFromSuperview()
            venueHourLabel4.removeFromSuperview()
            venueHourLabel5.removeFromSuperview()
            venueHourLabel6.removeFromSuperview()
        }
        
        if venue.links != "" {
            
            let reference = venue!.links.stringByReplacingOccurrencesOfString("[", withString: "")
            let links = reference.characters.split("]").map(String.init)
            
            var refs: [String] = []
            for value in links {
                let separation = value.componentsSeparatedByString(":::")
                let name = separation.first!.lowercaseString
                if name != "foursquare" && name != "yelp" && !name.containsString("google") {
                    refs.append(name.capitalizedString)
                }
            }
            if venue.website != "" {
                refs.insert("\(venue.name) Website", atIndex: 0)
            }
            
            for (index, value) in refs.enumerate() {
                if index == 0 {
                    venueLink0.text = value
                    venueLink0.userInteractionEnabled = true
                    let gesture = UITapGestureRecognizer(target: self, action: #selector(linkTapped))
                    venueLink0.addGestureRecognizer(gesture)
                }
                if index == 1 {
                    venueLink1.text = value
                    venueLink1.userInteractionEnabled = true
                    let gesture = UITapGestureRecognizer(target: self, action: #selector(linkTapped))
                    venueLink1.addGestureRecognizer(gesture)
                }
                if index == 2 {
                    venueLink2.text = value
                    venueLink2.userInteractionEnabled = true
                    let gesture = UITapGestureRecognizer(target: self, action: #selector(linkTapped))
                    venueLink2.addGestureRecognizer(gesture)
                }
                if index == 3 {
                    venueLink3.text = value
                    venueLink3.userInteractionEnabled = true
                    let gesture = UITapGestureRecognizer(target: self, action: #selector(linkTapped))
                    venueLink3.addGestureRecognizer(gesture)
                }
                if index == 4 {
                    venueLink4.text = value
                    venueLink4.userInteractionEnabled = true
                    let gesture = UITapGestureRecognizer(target: self, action: #selector(linkTapped))
                    venueLink4.addGestureRecognizer(gesture)
                }
                if index == 5 {
                    venueLink5.text = value
                    venueLink5.userInteractionEnabled = true
                    let gesture = UITapGestureRecognizer(target: self, action: #selector(linkTapped))
                    venueLink5.addGestureRecognizer(gesture)
                }
            }
            if venueLink5.text! == "" {
                venueLink5.removeFromSuperview()
                venueLinkViewHeight.constant = 205
            }
            if venueLink4.text! == "" {
                venueLink4.removeFromSuperview()
                venueLinkViewHeight.constant = 175
            }
            if venueLink3.text! == "" {
                venueLink3.removeFromSuperview()
                venueLinkViewHeight.constant = 145
            }
            if venueLink2.text! == "" {
                venueLink2.removeFromSuperview()
                venueLinkViewHeight.constant = 115
            }
            if venueLink1.text! == "" {
                venueLink1.removeFromSuperview()
                venueLinkViewHeight.constant = 85
            }
        }
        else {
            venueLinksImageView.removeFromSuperview()
            venueLinksTitleLabel.removeFromSuperview()
            venueLink0.removeFromSuperview()
            venueLink1.removeFromSuperview()
            venueLink2.removeFromSuperview()
            venueLink3.removeFromSuperview()
            venueLink4.removeFromSuperview()
            venueLink5.removeFromSuperview()
        }
    }
    
    func linkTapped(sender: UITapGestureRecognizer) {
        let button = sender.view as! UILabel!
        openLinkForName(button.text!)
    }
    
    func openLinkForName(org: String) {
        if org.containsString(venue.name) {
            performSegueWithIdentifier("showWebViewSegue", sender: venue.website)
        }
        else {
            let reference = venue!.links.stringByReplacingOccurrencesOfString("[", withString: "")
            let links = reference.characters.split("]").map(String.init)
            for value in links {
                let separation = value.componentsSeparatedByString(":::")
                let link = separation.last!
                let name = separation.first!.capitalizedString
                if name == org {
                    performSegueWithIdentifier("showWebViewSegue", sender: link)
                }
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showWebViewSegue" {
            let controller = segue.destinationViewController as? WebViewController
            controller?.hidesBottomBarWhenPushed = true
            controller!.URL = NSURL(string: sender as! String)!
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
