//
//  VenueDetailViewController.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import UIKit
import Mapbox
import iCarousel
import RealmSwift
import SDWebImage
import Localytics
import PhoneNumberKit

class VenueDetailViewController: UIViewController, MGLMapViewDelegate, iCarouselDataSource, iCarouselDelegate,  UIGestureRecognizerDelegate {
    
    @IBOutlet weak var vwContentHeight: NSLayoutConstraint!
    @IBOutlet weak var scMain: UIScrollView!
    @IBOutlet weak var vwContentView: UIView!
    @IBOutlet weak var carousel:            iCarousel!
    @IBOutlet weak var venueNameLabel:      UILabel!
    @IBOutlet weak var venueInfoLabel:      UILabel!
    @IBOutlet weak var venueBodyLabel:      UILabel!
    @IBOutlet weak var venueHoursLabel:     UILabel!
    @IBOutlet weak var venueLocationLabel:  UILabel!
    @IBOutlet weak var venueDistanceLabel:  UILabel!
    
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
    @IBOutlet weak var certifiedCategoryImage: UIImageView!
    @IBOutlet weak var certifiedImageView:     UIImageView!
    @IBOutlet weak var certifiedViewWidth:     NSLayoutConstraint!
    
    @IBOutlet weak var venueEventView:           UIView!
    @IBOutlet weak var venueEventOrganizerLabel: UILabel!
    @IBOutlet weak var venueEventLocationLabel:  UILabel!
    @IBOutlet weak var venueEventStartDateLabel: UILabel!
    @IBOutlet weak var venueEventEndDateLabel: UILabel!
    @IBOutlet weak var venueEventViewHeight:    NSLayoutConstraint!
    
    @IBOutlet weak var venueMapView:           MGLMapView!
    @IBOutlet weak var venueContactView:       UIView!
    @IBOutlet weak var venuePhoneLabel:        UILabel!
    @IBOutlet weak var venueAddressLabel:      UILabel!
    @IBOutlet weak var venueContactViewHeight: NSLayoutConstraint!
    @IBOutlet weak var venueOnlineImage: UIImageView!
    
    @IBOutlet weak var vwReview: UIView!
    @IBOutlet weak var vwReviewHeight: NSLayoutConstraint!
    @IBOutlet weak var venueOnlineIconView: UIImageView!
    @IBOutlet weak var venueOnlineButton: UIButton!
    @IBOutlet weak var vwReview1: UIView!
    @IBOutlet weak var vwReviewHeight1: NSLayoutConstraint!
    @IBOutlet weak var vwReview2: UIView!
    @IBOutlet weak var vwReviewHeight2: NSLayoutConstraint!
    @IBOutlet weak var vwReview3: UIView!
    @IBOutlet weak var vwReviewHeight3: NSLayoutConstraint!
    @IBOutlet weak var lblReviewTitle1: UILabel!
    @IBOutlet weak var lblReviewScore1: UILabel!
    @IBOutlet weak var txtReview1: UITextView!
    @IBOutlet weak var txtReviewHeight1: NSLayoutConstraint!
    @IBOutlet weak var lblReview2: UILabel!
    @IBOutlet weak var lblScore2: UILabel!
    @IBOutlet weak var txtReview2: UITextView!
    @IBOutlet weak var txtReviewHeight2: NSLayoutConstraint!
    @IBOutlet weak var lblReview3: UILabel!
    @IBOutlet weak var lblScore3: UILabel!
    @IBOutlet weak var txtReview3: UITextView!
    @IBOutlet weak var txtReviewHeight3: NSLayoutConstraint!
    @IBOutlet weak var lblReadFullReview1: UILabel!
    @IBOutlet weak var lblReadFullReview2: UILabel!
    @IBOutlet weak var lblReadFullReview3: UILabel!
    
    
    @IBOutlet weak var venueOnlineView:       UIView!
    @IBOutlet weak var venueOnlineViewHeight: NSLayoutConstraint!
    var reviewView : UIView!
    
    @IBAction func actionReview(sender: UIButton) {
        let rv = reviewArray[sender.tag]
        //        let url = NSURL(string: rv.link)
        performSegueWithIdentifier("showWebViewSegue", sender: rv.link)
    }
    
    
    @IBAction func venueOnlineButtonPressed(sender: AnyObject) {
        performSegueWithIdentifier("showWebViewSegue", sender: venue.website)
    }
    
    
    @IBOutlet weak var venueMoreInfoImage: UIImageView!
    @IBOutlet weak var venueMoreInfoButton: UIButton!
    @IBAction func moreInfoButtonPressed(sender: AnyObject) {
        performSegueWithIdentifier("showMoreInfoViewSegue", sender: venue)
    }

    @IBOutlet weak var favoriteButton: UIButton!
    @IBAction func favoriteButtonPressed(sender: AnyObject) {
        toggleFavoriteButton()
    }
    
    @IBAction func actionButtonPressed(sender: AnyObject) {
        shareButtonPressed()
    }
//    var deviceSize : CGSize!
    let realm = try! Realm()
    let sharedUI       = UIManager.sharedManager
    let sharedAPI      = APIManager.sharedManager
    let sharedStack    = RealmStack.sharedStack
    let sharedLocation = LocationManager.sharedManager
    
    var final = false
    var color: UIColor?
    var phone: PhoneNumber?
    var mediaURLs = [String]()
    var notificationToken: NotificationToken?
    var reviewArray : [Review] = [];
    
    
    var venue: Venue! {
        didSet {
            if !final {
                getVenueDetails()
            }
        }
    }

    override func viewDidLoad() {
        self.scMain.canCancelContentTouches = false
        self.hideReviewView()
        self.txtReview1.userInteractionEnabled = false;
        self.txtReview2.userInteractionEnabled = false;
        self.txtReview3.userInteractionEnabled = false;
//        self.scMain.delaysContentTouches = false
//        self.scMain.contentSize = CGSize(width: UIScreen.mainScreen().bounds.size.width, height: 2000)
        update()
        super.viewDidLoad()
        startNotificationToken()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
//        deviceSize = UIScreen.mainScreen().bounds.size
        
        Localytics.tagScreen("PlaceDetail")
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = false
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        stopNotificationToken()
    }
    
    func hideReviewView() {
        let size = vwReview.frame.size
        self.vwReview.alpha = 0
        self.scMain.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.width, self.scMain.frame.size.height - size.height)
//        vwReviewHeight.constant = 0
//        vwReview.alpha = 0;
    }
    
    func startNotificationToken() {
        notificationToken = realm.addNotificationBlock({ (notification, realm) in
            if !self.final {
                self.final = true
                self.reloadVenue()
            }
        })
    }
    
    func stopNotificationToken() {
        if let notificationToken = notificationToken {
            notificationToken.stop()
        }
    }
    
    func shareButtonPressed() {
        let URL = Constants.GWAPI.consumerURL + venue.slug + "/" + venue.id
        let content = "I found \(venue.name) on the Get Well Cities app! Check it out - "
        if let website = NSURL(string: URL) {
            let objects = [content, website]
            let activityVC = UIActivityViewController(activityItems: objects, applicationActivities: nil)
            activityVC.completionWithItemsHandler = {(activityType, completed:Bool, returnedItems:[AnyObject]?, error: NSError?) in
                if (!completed) {
                    return
                }
                Localytics.tagShared(self.venue.name, contentId: self.venue.id, contentType: "Venue", methodName: activityType, attributes: [:])
            }
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
    
    func toggleFavoriteButton() {
        if !venue.favorite {
            favoriteButton.selected = !favoriteButton.selected
            favoriteButton.tintColor = color!
        }
        else {
            favoriteButton.selected = !favoriteButton.selected
            favoriteButton.tintColor = UIColor.whiteColor()
        }
        sharedStack.favoriteCheck(venue)
    }
    
    func getVenueDetails() {
        sharedAPI.getVenueDetail(venue)
    }
    
    func reloadVenue() {
        let venueID = venue.id
        venue = realm.objects(Venue).filter("id == '\(venueID)'").first!
        parseReviewData(venue.reviews)
        update()
    }

    func update() {
        
        prepareCarousel()
        var category = venue.category.lowercaseString
        if category == "online" || category == "event" { category = venue.subcategory.lowercaseString }
        color = sharedUI.colorForCategory(category)

        title = venue.name
        venueNameLabel.text = venue.name
        venueBodyLabel.text = venue.info
        
        venueOnlineImage.tintColor = color
        venueMoreInfoImage.tintColor = color
        venueOnlineButton.tintColor = color
        venueMoreInfoButton.tintColor = color
        venueOnlineButton.setTitleColor(color, forState: .Normal)
        venueMoreInfoButton.setTitleColor(color, forState: .Normal)
        certifiedCategoryImage.tintColor = UIColor.whiteColor()
        
        if venue.openNow {
            venueHoursLabel.text = "Open Now"
        }
        else {
            venueHoursLabel.text = "Closed"
        }
        
        venueMapView.setCenterCoordinate(CLLocationCoordinate2DMake(venue!.latitude, venue!.longitude), zoomLevel: 13, animated: false)
        venueMapView.logoView.hidden = true

        venueMapView.zoomEnabled   = true
        venueMapView.scrollEnabled = true
        venueMapView.rotateEnabled = true
        venueMapView.pitchEnabled  = true
        venueMapView.attributionButton.hidden = true
        venueMapView.delegate = self
        setupAnnotation()
        
        displayCost(venue.cost)
        displayRate(venue.rate)
        
        venueLocationLabel.text = "\(venue.neighborhood), \(venue.city), \(venue.state)"
        venueAddressLabel.text  = "\(venue.address1), \(venue.city), \(venue.state), \(venue.zip) \n\(venue.crossStreet)"
        venueAddressLabel.setLineHeight(1.1)
        
        if venue.phone != "" {
            phone = try! PhoneNumber(rawNumber: venue.phone)
            venuePhoneLabel.text = phone!.toNational()
        }
        
        let phoneGesture = UITapGestureRecognizer(target: self, action: #selector(phoneTapped))
        venuePhoneLabel.userInteractionEnabled = true
        venuePhoneLabel.addGestureRecognizer(phoneGesture)
        
        let addressGesture = UITapGestureRecognizer(target: self, action: #selector(addressTapped))
        venueAddressLabel.userInteractionEnabled = true
        venueAddressLabel.addGestureRecognizer(addressGesture)
        
        venueNameLabel.textColor    = color
        venuePhoneLabel.textColor   = color
        venueAddressLabel.textColor = color
        
        certifiedCategoryImage.image  = sharedUI.imageForCategory(venue.category.lowercaseString)
        
        if venue.sort > 0 {
            venueDistanceLabel.text = "\(sharedUI.numberFormatter.stringFromNumber(venue.sort)!) miles"
        }
        else {
            if sharedLocation.status == .AuthorizedWhenInUse {
                venueDistanceLabel.text =  "\(sharedUI.numberFormatter.stringFromNumber(sharedLocation.returnDistance(venue.latitude, lng: venue.longitude))!) miles"
            }
        }
        
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
        
        if venue.subcategory != "" {
            venueInfoLabel.text = venue.subcategory
        }
        if !venue.certified {
            let bool = true
            certifiedViewWidth.constant = 58
            certifiedLabel.hidden       = bool
            certifiedImageView.hidden   = bool
            certifiedSeparator.hidden   = bool
        }
        else {
            let bool = false
            certifiedViewWidth.constant = 200
            certifiedLabel.hidden       = bool
            certifiedImageView.hidden   = bool
            certifiedSeparator.hidden   = bool
        }
        

        let type = venue.kind.lowercaseString
        if type == "event" {
            venueHoursLabel.text = ""
            let dates = venue.eventDates.componentsSeparatedByString(":::")
            venueEventOrganizerLabel.text = "Organizer:     \(venue.eventOrganizer)"
            venueEventLocationLabel.text  = "Venue:            \(venue.eventLocation)"
            venueEventStartDateLabel.text = "Starts:           \(dates.first!)"
            venueEventEndDateLabel.text   = "Ends:              \(dates.last!)"

        }
        else {
            venueEventView.hidden = true
            venueEventViewHeight.constant = 0
        }
        if type == "online" {
            hiddenCost(true)
            venueHoursLabel.text = ""
            venueLocationLabel.text = ""
            venueDistanceLabel.text = ""

            let website = sharedUI.parseURL(venue.website)
            if website != "" { venueDistanceLabel.text = website }
            venueOnlineImage.tintColor = color
            venueDistanceLabel.text = sharedUI.parseURL(venue.website)
            
            venueContactView.hidden = true
            venueContactViewHeight.constant = 0
        }
        else {
            hiddenCost(false)
            venueOnlineView.hidden = true
            venueOnlineViewHeight.constant = 0
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
    func parseReviewData(review : String) {
        reviewArray = []
        if review.characters.count > 0 {
            let reviewArr1 = review.componentsSeparatedByString("reviewmode: ")
            for i in 1  ..< reviewArr1.count  {
                let rv = reviewArr1[i]
                let rvObject = parseRevstack(rv)
                reviewArray.append(rvObject)
            }
        }
        if reviewArray.count > 0 {
            buildReviewView()
//            generateReviewView()
        } else {
            let constantY = self.venueMoreInfoButton.frame.origin.y + self.venueMoreInfoButton.frame.size.height + 16
            vwReview1.removeFromSuperview()
            vwReview2.removeFromSuperview()
            vwReview3.removeFromSuperview()
            vwReview.removeFromSuperview()
            
            vwContentHeight.constant = constantY
        }
    }
    func parseRevstack(stack : String) -> Review {
        let result : Review = Review()
        let arr1 = stack.componentsSeparatedByString("reviewsource: ")
        let arr2 = arr1[1].componentsSeparatedByString(" reviewscore: ")
        let arr3 = arr2[1].componentsSeparatedByString(" reviewlink: ")
        let arr4 = arr3[1].componentsSeparatedByString(" reviewsnippet: ")
        result.source = arr2[0]
        result.score = arr3[0]
        result.link = arr4[0]
        result.snippet = arr4[1]
        return result
    }
    func buildReviewView() {
        self.vwReview.alpha = 1
        var constant : CGFloat = 0
        switch reviewArray.count {
        case 0:
            constant = self.vwReview.frame.size.height
            self.vwReview.removeFromSuperview()
        case 1:
            constant = self.vwReview3.frame.size.height + self.vwReview2.frame.size.height
            self.vwReview3.removeFromSuperview()
            self.vwReview2.removeFromSuperview()
            putReviewInfo(1)
        case 2:
            constant = self.vwReview3.frame.size.height
            self.vwReview3.removeFromSuperview()
            putReviewInfo(2)
        case 3:
            constant = 0
            putReviewInfo(3)
        default:
            break
            
        }
        vwReviewHeight.constant -= constant
        vwContentHeight.constant -= constant
        
    }
    func putReviewInfo(count : Int) {
        var itemCount = count
        
        if reviewArray.count < itemCount {
            itemCount = Int(reviewArray.count)
        }
        for j in 0  ..< itemCount  {
            let rv = reviewArray[j]
            var prevConstant : CGFloat!
            var updatedConstant : CGFloat!
            var txtWidth : CGFloat!
            switch j {
            case 0:
                prevConstant = txtReview1.frame.size.height
                lblReviewTitle1.text = rv.source
                lblReadFullReview1.textColor = color
                lblReviewScore1.text = rv.score
                txtReview1.text = rv.snippet
                txtWidth = txtReview1.frame.size.width
                txtReview1.sizeThatFits(CGSize(width: txtWidth, height: CGFloat.max))
                let newSize = txtReview1.sizeThatFits(CGSize(width: txtWidth, height: CGFloat.max))
                var newFrame = txtReview1.frame
                newFrame.size = CGSize(width: txtWidth, height: newSize.height)
                updatedConstant = newFrame.size.height
//                txtReviewHeight1.constant = updatedConstant
                vwReviewHeight1.constant += updatedConstant - prevConstant
                vwReviewHeight.constant += updatedConstant - prevConstant
                let updatedContentHeight = vwReview.frame.origin.y + vwReviewHeight.constant
//                vwContentHeight.constant += updatedConstant - prevConstant
                vwContentHeight.constant = updatedContentHeight
            case 1:
                prevConstant = txtReview2.frame.size.height
                lblReview2.text = rv.source
                lblReadFullReview2.textColor = color
                lblScore2.text = rv.score
                txtReview2.text = rv.snippet
                txtWidth = txtReview2.frame.size.width
                txtReview2.sizeThatFits(CGSize(width: txtWidth, height: CGFloat.max))
                let newSize = txtReview2.sizeThatFits(CGSize(width: txtWidth, height: CGFloat.max))
                var newFrame = txtReview2.frame
                newFrame.size = CGSize(width: txtWidth, height: newSize.height)
                updatedConstant = newFrame.size.height
//                txtReviewHeight2.constant = updatedConstant
                vwReviewHeight2.constant += updatedConstant - prevConstant
                vwReviewHeight.constant += updatedConstant - prevConstant
//                vwContentHeight.constant += updatedConstant - prevConstant
                let updatedContentHeight = vwReview.frame.origin.y + vwReviewHeight.constant
                vwContentHeight.constant = updatedContentHeight
            case 2:
                prevConstant = txtReview3.frame.size.height
                lblReview3.text = rv.source
                lblReadFullReview3.textColor = color
                lblScore3.text = rv.score
                txtReview3.text = rv.snippet
//                txtReview3.textColor = color
                txtWidth = txtReview3.frame.size.width
                txtReview3.sizeThatFits(CGSize(width: txtWidth, height: CGFloat.max))
                let newSize = txtReview3.sizeThatFits(CGSize(width: txtWidth, height: CGFloat.max))
                var newFrame = txtReview3.frame
                newFrame.size = CGSize(width: txtWidth, height: newSize.height)
                updatedConstant = newFrame.size.height
//                txtReviewHeight3.constant = updatedConstant
                vwReviewHeight3.constant += updatedConstant - prevConstant
                vwReviewHeight.constant += updatedConstant - prevConstant
//                vwContentHeight.constant += updatedConstant - prevConstant
                let updatedContentHeight = vwReview.frame.origin.y + vwReviewHeight.constant
                vwContentHeight.constant = updatedContentHeight
            default:
                break
            }
        }
    }
    func generateReviewView() {
        let deviceSize = UIScreen.mainScreen().bounds.size
        var origin : CGFloat = venueMoreInfoButton.frame.origin.y + venueMoreInfoButton.frame.size.height + 24
//        var origin : CGFloat = 24
        let imgRev = UIImageView(frame: CGRectMake(16, origin, 24, 24))
        imgRev.image = UIImage(named: "icon-Review")
        
        let lblReview = UILabel(frame: CGRectMake(66, origin, 72, 24))
        lblReview.textAlignment = .Left
        lblReview.textColor = UIColor.blackColor()
        lblReview.text = "Reviews"
        lblReview.font = UIFont(name: ".SFUIDisplay-Light", size: 20)
        
//        self.vwReview.addSubview(imgRev)
//        self.vwReview.addSubview(lblReview)
        self.vwContentView.addSubview(imgRev)
        self.vwContentView.addSubview(lblReview)
        
        origin += 32
        
        for i in 0  ..< reviewArray.count {
            let rv = reviewArray[i]
            origin += 8
            let rvCell = generateReviewCell(origin,review: rv, tag: i)
//            self.vwReview.addSubview(rvCell)
            self.vwContentView.addSubview(rvCell)
            origin = origin + rvCell.frame.size.height + 5
            
            let lblbuttonTitle = UILabel(frame: CGRectMake(16,origin,deviceSize.width - 40,12))
            lblbuttonTitle.textAlignment = .Left
            lblbuttonTitle.font = UIFont.systemFontOfSize(10, weight: UIFontWeightSemibold)
            lblbuttonTitle.text = "Read Full Review"
            lblbuttonTitle.tag = i
            lblbuttonTitle.userInteractionEnabled = true
            lblbuttonTitle.textColor = color
//            let gesture = UITapGestureRecognizer(target: self, action: #selector(ReadFullReview))
////            gesture.delaysTouchesBegan = false
//            gesture.delegate = self;
//            lblbuttonTitle.addGestureRecognizer(gesture)
            let button = UIButton(type: .Custom) as UIButton
            button.frame = lblbuttonTitle.frame
            button.userInteractionEnabled = true
            button.addTarget(self, action: #selector(ReadFullReviewButton), forControlEvents: .TouchUpInside)
            
            button.userInteractionEnabled = true
//            self.vwReview.addSubview(lblbuttonTitle)
//            self.vwReview.addSubview(button)
            self.vwContentView.addSubview(lblbuttonTitle)
            self.vwContentView.addSubview(button)
            
            origin = origin + lblbuttonTitle.frame.size.height + 8
        }
//        self.vwReview.frame = CGRectMake(self.vwReview.frame.origin.x, self.vwReview.frame.origin.y, UIScreen.mainScreen().bounds.size.width, origin)
//        let contentSizeY : CGFloat = venueMoreInfoButton.frame.origin.y + venueMoreInfoButton.frame.size.height + origin
        let scVw : UIScrollView = self.vwContentView.superview as! UIScrollView;
        scVw.contentSize = CGSize(width: UIScreen.mainScreen().bounds.size.width, height: origin)
//        self.scMain.contentSize = CGSize(width: UIScreen.mainScreen().bounds.size.width, height: contentSizeY)
    }
    func generateReviewCell(originY : CGFloat, review : Review, tag: Int) -> UIView {
        let deviceSize = UIScreen.mainScreen().bounds.size
        let lblSource = UILabel(frame: CGRectMake(16,0,deviceSize.width - 140,19))
        lblSource.textAlignment = .Left
        lblSource.textColor = UIColor.blackColor()
        lblSource.font = UIFont.systemFontOfSize(16)
        lblSource.text = review.source
        
        let lblScore = UILabel(frame: CGRectMake(deviceSize.width - 124,5,100,14))
        lblScore.textAlignment = .Right
        lblScore.textColor = UIColor(red: 74 / 255, green: 74 / 255, blue: 74 / 255, alpha: 1)
        lblScore.font = UIFont.systemFontOfSize(12, weight: UIFontWeightSemibold)
        lblScore.text = review.score
        
        let txtReview = UITextView(frame: CGRectMake(10, 27, deviceSize.width - 20, 100))
        let txtReviewWidth = deviceSize.width - 20
        txtReview.textAlignment = .Left
        txtReview.scrollEnabled = false
        txtReview.textColor = UIColor(red: 74 / 255, green: 74 / 255, blue: 74 / 255, alpha: 1)
        txtReview.font = UIFont(name: ".SFUIText-Italic", size: 14)
        txtReview.text = review.snippet
        txtReview.sizeThatFits(CGSize(width: txtReviewWidth, height: CGFloat.max))
        let newSize = txtReview.sizeThatFits(CGSize(width: txtReviewWidth, height: CGFloat.max))
        var newFrame = txtReview.frame
        newFrame.size = CGSize(width: txtReviewWidth, height: newSize.height)
        txtReview.frame = newFrame
        
//        let lblbuttonTitle = UILabel(frame: CGRectMake(16,newFrame.origin.y + newFrame.size.height + 8,deviceSize.width - 40,12))
//        lblbuttonTitle.textAlignment = .Left
//        lblbuttonTitle.font = UIFont.systemFontOfSize(10, weight: UIFontWeightSemibold)
//        lblbuttonTitle.text = "Read Full Review"
//        lblbuttonTitle.textColor = UIColor(red: 20 / 255, green: 125 / 255, blue: 135 / 255, alpha: 1)
//        let button = UIButton(frame: lblbuttonTitle.frame)
//        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(ReadFullReview))
//        tapGesture.delegate = self
//        button.tag = tag
//        button.addGestureRecognizer(tapGesture)
//        button.userInteractionEnabled = true
        let vwFrame = CGRectMake(0, originY, deviceSize.width, newFrame.origin.y + newFrame.size.height)
        let reviewCell  = UIView(frame: vwFrame)
        
        reviewCell.addSubview(lblSource)
        reviewCell.addSubview(lblScore)
        reviewCell.addSubview(txtReview)
        
        return reviewCell
    }
    func ReadFullReviewButton(button : UIButton) {
//        let lb = gesture.view
        let rv = reviewArray[button.tag]
        //        let url = NSURL(string: rv.link)
        performSegueWithIdentifier("showWebViewSegue", sender: rv.link)
    }
    func ReadFullReview(gesture : UITapGestureRecognizer) {
        let lb = gesture.view
        let rv = reviewArray[lb!.tag]
//        let url = NSURL(string: rv.link)
        performSegueWithIdentifier("showWebViewSegue", sender: rv.link)
    }
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        
        return true;
    }
    
    func hiddenCost(value: Bool) {
        imageCost1.hidden = value
        imageCost2.hidden = value
        imageCost3.hidden = value
        imageCost4.hidden = value
        imageCost5.hidden = value
    }
    
    func phoneTapped(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "tel://\(phone!.nationalNumber)")!)
    }
    
    func addressTapped(sender: AnyObject) {
        
        let parameters = "\(venue.address1) \(venue.city) \(venue.state) \(venue.zip)".stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        if UIApplication.sharedApplication().canOpenURL(NSURL(string: "comgooglemaps://")!) {
            let URL = NSURL(string: "comgooglemaps://?q=\(parameters)")!
            UIApplication.sharedApplication().openURL(URL)
        }
        else {
            let URL = NSURL(string: "http://maps.apple.com/?address=\(parameters)")!
            UIApplication.sharedApplication().openURL(URL)
        }
    }
    
    func setupAnnotation() {
        var category = venue.category.lowercaseString
        if category == "online" || category == "event" { category = venue.subcategory.lowercaseString }
        if category == "eat" {
            let eat = MAPPointEatAnnotation()
            eat.coordinate = CLLocationCoordinate2DMake(venue.latitude, venue.longitude)
            eat.title    = venue.name
            eat.subtitle = venue.address1
            venueMapView.addAnnotation(eat)
        }
        if category == "move" {
            let move = MAPPointMoveAnnotation()
            move.coordinate = CLLocationCoordinate2DMake(venue.latitude, venue.longitude)
            move.title    = venue.name
            move.subtitle = venue.address1
            venueMapView.addAnnotation(move)
        }
        if category == "heal" {
            let heal = MAPPointHealAnnotation()
            heal.coordinate = CLLocationCoordinate2DMake(venue.latitude, venue.longitude)
            heal.title    = venue.name
            heal.subtitle = venue.address1
            venueMapView.addAnnotation(heal)
        }
    }
    
    func mapView(mapView: MGLMapView, imageForAnnotation annotation: MGLAnnotation) -> MGLAnnotationImage? {
        if annotation.isKindOfClass(MAPPointEatAnnotation) {
            var annotationImage  = mapView.dequeueReusableAnnotationImageWithIdentifier("eat")
            if annotationImage == nil {
                var image = UIImage(named: "icon-Marker-Eat")!
                image = image.imageWithAlignmentRectInsets(UIEdgeInsetsMake(0, 0, image.size.height/2, 0))
                annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "eat")
            }
            return annotationImage
        }
        if annotation.isKindOfClass(MAPPointMoveAnnotation) {
            var annotationImage  = mapView.dequeueReusableAnnotationImageWithIdentifier("move")
            if annotationImage == nil {
                var image = UIImage(named: "icon-Marker-Move")!
                image = image.imageWithAlignmentRectInsets(UIEdgeInsetsMake(0, 0, image.size.height/2, 0))
                annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "move")
            }
            return annotationImage
        }
        if annotation.isKindOfClass(MAPPointHealAnnotation) {
            var annotationImage  = mapView.dequeueReusableAnnotationImageWithIdentifier("heal")
            if annotationImage == nil {
                var image = UIImage(named: "icon-Marker-Heal")!
                image = image.imageWithAlignmentRectInsets(UIEdgeInsetsMake(0, 0, image.size.height/2, 0))
                annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "heal")
            }
            return annotationImage
        }
        return nil
    }
    
    
    func mapView(mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func carouselItemWidth(carousel: iCarousel) -> CGFloat {
        return carousel.frame.width
    }
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int {
        return mediaURLs.count
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView {
        var item: UIImageView
        if view == nil {
            item = UIImageView(frame: CGRectMake(0, 0, carousel.bounds.width, carousel.frame.height))
            item.backgroundColor = sharedUI.colorBackground
            item.contentMode = .ScaleAspectFill
            item.sd_setImageWithURL(NSURL(string: mediaURLs[index]))
        }
        else {
            item = view as! UIImageView
        }
        return item
    }
    
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if option == .Wrap {
            return 1
        }
        return value
    }
    
    func prepareCarousel() {
        
        if venue.media.containsString("[") {
            let reference = venue.media.stringByReplacingOccurrencesOfString("[", withString: " ").stringByReplacingOccurrencesOfString("]", withString: "")
            let medias = reference.characters.split(" ").map(String.init)
            for media in medias {
                let URL = NSMutableString(string: media)
                URL.insertString(sharedUI.ratio, atIndex: sharedUI.index)
                if !mediaURLs.contains(URL as String) {
                    mediaURLs.append(URL as String)
                }
            }
        }
        else if venue.poster != "" {
            let URL = NSMutableString(string: venue.poster)
            URL.insertString(sharedUI.ratio, atIndex: sharedUI.index)
            mediaURLs.append(URL as String)
        }
        else {
            let URL = NSMutableString(string: sharedUI.categoryImageURL(venue.category.lowercaseString))
            URL.insertString(sharedUI.ratio, atIndex: sharedUI.index)
            if !mediaURLs.contains(URL as String) {
                mediaURLs.append(URL as String)
            }
        }
        SDWebImagePrefetcher.sharedImagePrefetcher().prefetchURLs(mediaURLs)
        carousel.delegate = self
        carousel.dataSource = self
        carousel.decelerationRate = 0.5
        carousel.type = .Linear
        
        if mediaURLs.count == 1 {
            carousel.scrollEnabled = false
        }
        else {
            carousel.scrollEnabled = true
        }
        carousel.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMoreInfoViewSegue" {
            let controller = segue.destinationViewController as? VenueInfoViewController
            controller!.venue = sender as? Venue
        }
        if segue.identifier == "showWebViewSegue" {
            let controller = segue.destinationViewController as? WebViewController
            controller?.hidesBottomBarWhenPushed = true
            controller!.URL = NSURL(string: sender as! String)!
        }
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
extension VenueDetailViewController : UIScrollViewDelegate {
    func touchesShouldCancelInContentView(view: UIView) -> Bool {
        return !view.isKindOfClass(UIButton)
    }
}
