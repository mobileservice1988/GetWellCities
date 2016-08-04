//
//  HomeTableViewController.swift
//  Copyright © 2016 Get Well. All rights reserved.
//

import UIKit
import Localytics
import MXParallaxHeader

class HomeViewController: UITableViewController, StackDelegate, UITabBarControllerDelegate {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var greetLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBAction func unwindToHome(segue: UIStoryboardSegue) {}
    var imageHeader : UIImageView!
    var indicatorView : UIView!
    var imgHeaderData : NSData!
    
    
    let sharedUI         = UIManager.sharedManager
    let sharedAuth       = AuthManager.sharedManager
    let sharedStack      = RealmStack.sharedStack
    let sharedLocation   = LocationManager.sharedManager
    
    let appDelegate      = UIApplication.sharedApplication().delegate as! AppDelegate
    let tabbarController = UIApplication.sharedApplication().keyWindow?.rootViewController as! UITabBarController
    var defaultOffset : CGPoint = CGPointZero
    var timer : NSTimer!
    var currentTime : CGFloat = 0
    var isRegionChanged = false
    var isSliderChanged = false
    var isFeaturedChanged = false
    var isPushToRefresh = false;
    var storedOffsets  = [Int: CGFloat]()
    var isImportRegionDone = false;
    var isImportSliderDone = false;
    var sources  = [SlideObject]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    var regions = [Region]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SwitchedToForeground), name: Constants.Notification.BGMode, object: nil)
        let view = UIView.init(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width,20))
        view.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(view)
        tabbarController.delegate = self
        if sharedAuth.isLoggedIn() { self.tabBarController!.tabBar.hidden = false }
        super.viewDidLoad()
        
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        setupParallaxHeader()
        setupSearchButton()
        setupIndicatorView()
        
        sharedStack.delegate = self
        
        imageHeader = self.tableView.parallaxHeader.view?.viewWithTag(100) as! UIImageView;
        
        defaultOffset = self.tableView.contentOffset
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = true
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Localytics.tagScreen("Home")
        greetLabel.text = "Good " + sharedUI.currentTime() + "!"
        
        if imgHeaderData != nil {
            self.imageHeader!.image = UIImage(data: imgHeaderData);
        } else {
            var imgUrl : NSURL!
            //        sharedUI.time = .morning
            switch sharedUI.time {
            case .morning:
                imgUrl = NSURL(string: Constants.GWAPI.hero_mor_URL);
                break
            case .afternoon:
                imgUrl = NSURL(string: Constants.GWAPI.hero_aft_URL);
                break
            case .evening:
                imgUrl = NSURL(string: Constants.GWAPI.hero_eve_URL);
                break
            case .night:
                imgUrl = NSURL(string: Constants.GWAPI.hero_night_URL);
                break
            }
            NSURLSession.sharedSession().dataTaskWithURL(imgUrl!, completionHandler: { (data, response, error) in
                if data != nil && error == nil {
                    let image : UIImage = UIImage(data: data!)!;
                    self.imgHeaderData = data
                    dispatch_async(dispatch_get_main_queue(), {
//                        self.imageHeader!.image = image
                        UIView.transitionWithView(self.imageHeader
                            ,duration: 0.2
                            ,options: UIViewAnimationOptions.TransitionCrossDissolve
                            ,animations: {
                                self.imageHeader.image = image
                            }
                            ,completion: {(finished) in
                        })
                    })
                }
                
            }).resume()
        }
        tableView.reloadData()
        if appDelegate.quickSearch == 1 {
            presentSearch()
            appDelegate.quickSearch = 0
        }
    }
    func SwitchedToForeground() {
        pullToRefresh()
    }
    func heroImageRefresh() {
        greetLabel.text = "Good " + sharedUI.currentTime() + "!"
        var imgUrl : NSURL!
        //        sharedUI.time = .morning
        switch sharedUI.time {
        case .morning:
            imgUrl = NSURL(string: Constants.GWAPI.hero_mor_URL);
            break
        case .afternoon:
            imgUrl = NSURL(string: Constants.GWAPI.hero_aft_URL);
            break
        case .evening:
            imgUrl = NSURL(string: Constants.GWAPI.hero_eve_URL);
            break
        case .night:
            imgUrl = NSURL(string: Constants.GWAPI.hero_night_URL);
            break
        }
        NSURLSession.sharedSession().dataTaskWithURL(imgUrl!, completionHandler: { (data, response, error) in
            if data != nil && error == nil {
                let image : UIImage = UIImage(data: data!)!;
                self.imgHeaderData = data
                dispatch_async(dispatch_get_main_queue(), {
//                    self.imageHeader!.image = image
                    UIView.transitionWithView(self.imageHeader
                        ,duration: 0.2
                        ,options: UIViewAnimationOptions.TransitionCrossDissolve
                        ,animations: {
                            self.imageHeader.image = image
                        }
                        ,completion: {(finished) in
                    })
                })
            }
            
        }).resume()
    }
    func setupIndicatorView() {
        indicatorView = UIView(frame: CGRectMake(0, 0, tableView.frame.width, 100))
        indicatorView.backgroundColor = UIColor.clearColor()
        let pagingSpinner = UIActivityIndicatorView(activityIndicatorStyle:.White)
        pagingSpinner.center = indicatorView.center
        pagingSpinner.startAnimating()
        pagingSpinner.color = UIColor(red: 170.0/255.0, green: 170.0/255.0, blue: 170.0/255.0, alpha: 1.0)
        pagingSpinner.hidesWhenStopped = true
        indicatorView.addSubview(pagingSpinner)
        self.tableView.parallaxHeader.view!.addSubview(indicatorView)
        indicatorView.alpha = 0
    }
    func setupParallaxHeader() {
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let minus = headerView.bounds.height + tabBarController!.tabBar.bounds.size.height
        self.tableView.parallaxHeader.view = NSBundle.mainBundle().loadNibNamed("HomeHeader", owner: self, options: nil).first as? UIView
        self.tableView.parallaxHeader.height = screenSize.height - minus
        self.tableView.parallaxHeader.mode = .Fill
        self.tableView.parallaxHeader.minimumHeight = 20
    }
    
    func delegateUpdate() {
        if sharedStack.source.count != 0 {
            sources  = sharedStack.source
        }
        if sharedStack.processedRegions.count != 0 {
            sharedStack.relocateRegions()
            regions = sharedStack.processedRegions
        }
    }
    
    func regionImportDone() {
        if isPushToRefresh {
            isImportRegionDone = true
            if isImportSliderDone && currentTime > 2.0{
                dismissIndicator()
            }
        }
//        if isRegionChanged == false {
//            sharedStack.prepareRegions()
//            isRegionChanged = true
//        } else {
//            regions = sharedStack.processedRegions
//            isRegionChanged = false
//        }
        sharedStack.relocateRegions()
        regions = sharedStack.processedRegions
        
    }
    
    func sliderImportDone() {
        if isPushToRefresh {
            isImportSliderDone = true
            if isImportRegionDone && currentTime > 2.0 {
                dismissIndicator()
            }
        }
//        if isSliderChanged == false {
//            sharedStack.prepareSliderObjects()
//            isSliderChanged = true
//        } else {
//            sources = sharedStack.source
//            isSliderChanged = false
//        }
        sources = sharedStack.source
        
    }
    
    func regionDistanceDone() {
        sharedStack.relocateRegions()
        regions = sharedStack.processedRegions
    }
    
    func setupSearchButton() {
        let button = UIButton(type: .Custom) as UIButton
        button.frame = CGRectMake(14, headerView.frame.origin.x - 52, 64, 64)
        button.imageView?.tintColor = UIColor.whiteColor()
        button.backgroundColor = UIColor ( red: 0.0392, green: 0.3333, blue: 0.4706, alpha: 1.0 )
        button.layer.borderWidth  = 2
        button.layer.borderColor  = UIColor.whiteColor().CGColor
        button.layer.cornerRadius = 0.5 * button.bounds.size.width
        button.setImage(UIImage(named:"icon-Search"), forState: .Normal)
        button.addTarget(self, action: #selector(presentSearch), forControlEvents: .TouchUpInside)
        view.addSubview(button)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 { return 285 }
        if indexPath.section == 1 { return 285 }
        if indexPath.section == 2 { return 285 }
        if indexPath.section == 3 { return 460 }
        return 0
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 { return 285 }
        if indexPath.section == 1 { return 285 }
        if indexPath.section == 2 { return 285 }
        if indexPath.section == 3 { return 460 }
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        if section == 1 { return regions.count }
        if section == 2 { return 1 }
        if section == 3 { return sources.count }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("RegionCell", forIndexPath: indexPath) as! RegionTableViewCell
            cell.index = indexPath.section
            return cell
        }
        if indexPath.section == 1 {
            let cell = tableView.dequeueReusableCellWithIdentifier("RegionCell", forIndexPath: indexPath) as! RegionTableViewCell
            cell.region = regions[indexPath.row]
            return cell
        }
        if indexPath.section == 2 {
            let cell = tableView.dequeueReusableCellWithIdentifier("RegionCell", forIndexPath: indexPath) as! RegionTableViewCell
            cell.index = indexPath.section
            return cell
        }
        if indexPath.section == 3 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SliderTableCell", forIndexPath: indexPath) as! SliderTableViewCell
            cell.slideObject = sources[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let sectionOneSeparatorThickness = CGFloat(2)
        let sectionOneSeparator = UIView(frame: CGRectMake(0, cell.frame.size.height - sectionOneSeparatorThickness, cell.frame.size.width, sectionOneSeparatorThickness))
        sectionOneSeparator.backgroundColor = UIColor.whiteColor()
        let sectionTwoSeparatorThickness = CGFloat(1)
        let sectionTwoSeparator = UIView(frame: CGRectMake(0, cell.frame.size.height - sectionTwoSeparatorThickness, cell.frame.size.width, sectionTwoSeparatorThickness))
        sectionTwoSeparator.backgroundColor = UIColor ( red: 0.9255, green: 0.9255, blue: 0.9529, alpha: 1.0 )
        switch (indexPath.section) {
        case 0:
            cell.addSubview(sectionOneSeparator)
        case 1:
            cell as! RegionTableViewCell
            cell.addSubview(sectionOneSeparator)
        case 2:
            cell.addSubview(sectionOneSeparator)
        case 3:
            guard let tableViewCell = cell as? SliderTableViewCell else { return }
            tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
            tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
            cell.addSubview(sectionTwoSeparator)
        default:
            print("")
        }
    }
    
    override func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let tableViewCell = cell as? SliderTableViewCell else { return }
        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 { navigateToConcierge() }
        if indexPath.section == 1 {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! RegionTableViewCell
            performSegueWithIdentifier("showVenueListSegue", sender: cell.region) }
        if indexPath.section == 2 { navigateToFavorites() }
    }
    
    func navigateToFavorites() {
        tabBarController?.selectedIndex = 1
    }
    func navigateToConcierge() {
        tabBarController?.selectedIndex = 2
    }
    
    func presentSearch() {
        performSegueWithIdentifier("showSearchViewSegue", sender: nil)
    }
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if self.tabbarController.selectedIndex == 0 && viewController == self.tabbarController.viewControllers![0] {
            return false
        }
        else {
            return true
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showVenueListSegue" {
            let controller = segue.destinationViewController as? VenueListViewController
            controller?.region = sender as? Region
        }
        if segue.identifier == "showVenueDetailSegue" {
            let controller = segue.destinationViewController as? VenueDetailViewController
            controller?.hidesBottomBarWhenPushed = true
            controller!.venue = sender as? Venue
        }
    }
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        if scrollView == self.tableView {
            
            if (defaultOffset != CGPointZero && offset.y < defaultOffset.y-65)  {
                if isPushToRefresh == false {
                    pullToRefresh()
                }
            }
        }
        
    }
    func pullToRefresh() {
        indicatorView.alpha = 1
        isPushToRefresh = true
        heroImageRefresh()
        refreshDb()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: #selector(HomeViewController.countTime), userInfo: nil, repeats: true)
        
    }
    func dismissIndicator() {
        indicatorView.alpha = 0
        currentTime = 0
        isImportRegionDone = false;
        isImportSliderDone = false;
        isPushToRefresh = false;
        if (timer != nil) {
            timer.invalidate()
            timer = nil
        }
        
    }
    func refreshDb() {
        sharedStack.refresh()
    }
    
    func countTime() {
        currentTime = currentTime + 0.2
        if currentTime > 4.0 {
            dismissIndicator()
        }
    }
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sources[collectionView.tag].objects.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("SliderCollectionCell", forIndexPath: indexPath) as! SliderCollectionViewCell
        cell.venue = sources[collectionView.tag].objects![indexPath.item]
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        //        print("Collection view at row \(collectionView.tag) selected index path \(indexPath)")
        let cell = collectionView.cellForItemAtIndexPath(indexPath) as! SliderCollectionViewCell
        performSegueWithIdentifier("showVenueDetailSegue", sender: cell.venue)
        
    }
}