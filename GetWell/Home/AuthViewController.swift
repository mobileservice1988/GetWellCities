//
//  AuthViewController.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Localytics

class AuthViewController: UIViewController, UIScrollViewDelegate {

    var player: AVPlayer?
    let sharedUI = UIManager.sharedManager
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let screen = UIScreen.mainScreen()
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var buttonSignin: UIButton!
    @IBOutlet weak var buttonSignup: UIButton!
    
    @IBAction func buttonPressed(sender: AnyObject) {
        let action: String
        if sender as! NSObject == self.buttonSignin { action = "signin" }
        else { action = "signup" }
        performSegueWithIdentifier("showAuthViewSegue", sender: action)
    }
    
    override func viewDidLoad() {
        showOnboard()
        super.viewDidLoad()
        delegate.customizeAppearance()
        scrollView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        Localytics.tagScreen("VideoAuth")
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView){
        let pageWidth: CGFloat = CGRectGetWidth(scrollView.frame)
        let currentPage: CGFloat = floor((scrollView.contentOffset.x - pageWidth/2) / pageWidth) + 1
        self.pageControl.currentPage = Int(currentPage)
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    func showOnboard() {
        let playerLayer = AVPlayerLayer(player: self.sharedUI.player)
        playerLayer.backgroundColor = UIColor.blackColor().CGColor
        playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        playerLayer.zPosition = -1
        
        loopVideo()
        self.sharedUI.player!.play()
        let container = UIView(frame: CGRectMake(0, 0, screen.bounds.width, screen.bounds.height))
        container.backgroundColor = UIColor.redColor()
        playerLayer.frame = container.frame
        container.layer.addSublayer(playerLayer)
        view.insertSubview(container, atIndex: 0)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loopVideo), name: AVPlayerItemDidPlayToEndTimeNotification, object: nil)
    }
    
    func loopVideo() {
        sharedUI.player?.seekToTime(kCMTimeZero)
        sharedUI.player?.play()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showAuthViewSegue" {
            let controller = segue.destinationViewController as? SignViewController
            controller?.action = (sender as! String)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
