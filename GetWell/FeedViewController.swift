//
//  FeedViewController.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import UIKit
import TwitterKit
import Localytics

class FeedViewController: TWTRTimelineViewController, TWTRTweetViewDelegate {

    override func viewDidLoad() {
        let client = TWTRAPIClient()
        self.dataSource = TWTRUserTimelineDataSource(screenName: "GetWellCities", APIClient: client)
        self.tweetViewDelegate = self
        self.showTweetActions = false
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Localytics.tagScreen("TwitterFeed")
    }

    
//    func tweetView(tweetView: TWTRTweetView, didTapImage image: UIImage, withURL imageURL: NSURL) {
////        let view = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, 20))
////        view.backgroundColor = UIColor.blackColor()
////        self.view.addSubview(view)
//    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
