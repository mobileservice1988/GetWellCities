//
//  RegionSelectorVC.swift
//  GetWell
//
//  Created by mac on 7/26/16.
//  Copyright © 2016 Beakyn Company. All rights reserved.
//

import UIKit
import Localytics
import SDWebImage
import RealmSwift

class RegionSelectorVC: UIViewController, StackDelegate{

    @IBOutlet weak var tblView: UITableView!
    private let realm = try! Realm()
    let sharedUI         = UIManager.sharedManager
    let sharedAuth       = AuthManager.sharedManager
    let sharedStack      = RealmStack.sharedStack
    let sharedLocation   = LocationManager.sharedManager
    var regions = [Region]() {
        didSet {
            self.tblView.reloadData()
        }
    }
    var sources  = [SlideObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.tabBarController!.tabBar.hidden = true
        sharedStack.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func regionImportDone() {
        regions = sharedStack.processedRegions
        self.tblView.reloadData()
    }
    func delegateUpdate() {
        if sharedStack.source.count != 0 {
            sources  = sharedStack.source
        }
        if sharedStack.processedRegions.count != 0 {
            regions = sharedStack.processedRegions
        }
    }
    func sliderImportDone() {
        sources = sharedStack.source
    }
    
    func regionDistanceDone() {
        regions = sharedStack.processedRegions
    }
}
extension RegionSelectorVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return regions.count
    }
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 135
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("RegionCell", forIndexPath: indexPath) as! RegionSelectionCell
        let region = regions[indexPath.row]
        cell.lblRegionName.text = region.name
        let placeholder = sharedUI.imagePlaceholder
        if region.image != "" {
            //                    let URL = NSMutableString(string: region.image)
            //                    URL.insertString(sharedUI.ratio, atIndex: 50)
            SDWebImageManager.sharedManager().downloadImageWithURL(NSURL(string: region.image), options: .RetryFailed, progress: { (receivedSize: Int, expectedSize: Int) in
                }, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, finished: Bool, url: NSURL!) in
                    if error != nil {
                        print("Error: \(error.userInfo)")
                    }
                    if image != nil {
                        cell.imgRegion.image = image
                    }
                    else {
                        UIView.transitionWithView(cell.imgRegion
                            ,duration: 0.2
                            ,options: UIViewAnimationOptions.TransitionCrossDissolve
                            ,animations: {
                                cell.imgRegion.image = image
                            }
                            ,completion: {(finished) in
                        })
                    }
            })
        }
        else {
            cell.imgRegion.image = placeholder
        }
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let region = regions[indexPath.row]
        sharedStack.defaultRegion = region
        sharedStack.initializeDefaultRegion()
        let defRegion = DefaultRegion()
        defRegion.initWithRegion(region)
        let realm = try! Realm()
        try! realm.write({
            realm.create(DefaultRegion.self, value: defRegion, update: true)
        })
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isRegionSelected")
        performSegueWithIdentifier("showHomeVC", sender: nil)
    }
}