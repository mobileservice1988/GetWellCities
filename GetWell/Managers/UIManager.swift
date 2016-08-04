//
//  UIManager.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation
import QuartzCore

enum Greet : String {
    case morning
    case afternoon
    case evening
    case night
}

enum Rate: Double {
    case Rate00 = 0.0
    case Rate05 = 0.5
    case Rate10 = 1.0
    case Rate15 = 1.5
    case Rate20 = 2.0
    case Rate25 = 2.5
    case Rate30 = 3.0
    case Rate35 = 3.5
    case Rate40 = 4.0
    case Rate45 = 4.5
    case Rate50 = 5.0
}

enum Cost: Int {
    case Cost0 = 0
    case Cost1 = 1
    case Cost2 = 2
    case Cost3 = 3
    case Cost4 = 4
    case Cost5 = 5
}

class UIManager: NSObject {
    
    static let sharedManager = UIManager()
    
    var time: Greet = .morning
    var player: AVPlayer?
    var videoAsset: AVAsset?
    var playerItem: AVPlayerItem?
    let numberFormatter = NSNumberFormatter()
    
    // Manages number of venues displayed per page on Venue List view
    var pageSize = 100
    var mapsize = 50
    let preloadSize = 5
    
    let index    = 50
    let ratio        = "t_iphone/"
    let legacyRation = "if_ar_gt_4:3,ar_4:3,h_1.0,c_fill/if_else,ar_4:3,w_1.0,c_fill/if_end/"
    let videoURL     = "http://res.cloudinary.com/hbab5hodz/video/upload/ac_none,br_128,c_scale,h_667,vc_auto,w_375/v1459521603/onboarding.mp4"
    
    let imageEatURL  = "https://res.cloudinary.com/hbab5hodz/image/upload/v1460394625/UI_-_3_ioaslw.png"
    let imageHealURL = "http://res.cloudinary.com/hbab5hodz/image/upload/v1460394625/UI_-_2_qxcfoo.png"
    let imageMoveURL = "https://res.cloudinary.com/hbab5hodz/image/upload/v1460394625/UI_-_1_i9607t.png"
    
    let colorEat    = UIColor(red: 0.0, green: 0.4314, blue: 0.4588, alpha: 1.0)
    let colorMove   = UIColor(red: 0.6706, green: 0.0, blue: 0.1373, alpha: 1.0)
    let colorHeal   = UIColor(red: 0.3255, green: 0.2118, blue: 0.3608, alpha: 1.0)
    let colorOnline = UIColor(red: 0.0, green: 0.2667, blue: 0.4, alpha: 1.0)
    let colorEvent  = UIColor(red: 0.0, green: 0.2667, blue: 0.4, alpha: 1.0)
    
    let colorMain       = UIColor (red: 0.0, green: 0.2667, blue: 0.4, alpha: 1.0)
    let colorRate       = UIColor (red: 1.0, green: 0.749, blue: 0.1412, alpha: 1.0)
    let colorCost       = UIColor (red: 0.4431, green: 0.6549, blue: 0.3569, alpha: 1.0)
    let colorFavorite   = UIColor (red: 0.9686, green: 0.6626, blue: 0.6475, alpha: 1.0)
    let colorBackground = UIColor (red: 0.9373, green: 0.9373, blue: 0.9373, alpha: 1.0)

    let favoriteTitle  = "Favorites"
    let conciergeTitle = "Chat"
    let conciergeDesc  = "Connect with a Wellness Concierge"
    
    let iconSlideEat    = UIImage(named: "icon-Eat")!
    let iconSlideMove   = UIImage(named: "icon-Move")!
    let iconSlideHeal   = UIImage(named: "icon-Heal")!
    let iconSlideEvent  = UIImage(named: "icon-Event")!
    let iconSlideOnline = UIImage(named: "icon-Online")!
    
    let imageHomeFavorite  = UIImage(named: "image-Home-Favorite")
    let imageHomeConcierge = UIImage(named: "image-Home-Concierge")
    let imageDisclose      = UIImage(named: "icon-Disclose-Indicator")
    let imageRateEmpty     = UIImage(named: "icon-Rate-Empty")!.imageWithRenderingMode(.AlwaysTemplate)
    let imageRateHalf      = UIImage(named: "icon-Rate-Half")!.imageWithRenderingMode(.AlwaysTemplate)
    let imageRateFull      = UIImage(named: "icon-Rate-Full")!.imageWithRenderingMode(.AlwaysTemplate)
    let imageCostEmpty     = UIImage(named: "icon-Cost-Empty")!.imageWithRenderingMode(.AlwaysTemplate)
    let imageCostFull      = UIImage(named: "icon-Cost-Full")!.imageWithRenderingMode(.AlwaysTemplate)
    let imagePlainEAT      = UIImage(named: "icon-Eat-Plain")!.imageWithRenderingMode(.AlwaysTemplate)
    let imagePlainMOVE     = UIImage(named: "icon-Move-Plain")!.imageWithRenderingMode(.AlwaysTemplate)
    let imagePlainHEAL     = UIImage(named: "icon-Heal-Plain")!.imageWithRenderingMode(.AlwaysTemplate)
    let imagePlainWEB      = UIImage(named: "icon-Web-Plain")!.imageWithRenderingMode(.AlwaysTemplate)
    let imagePlainEVENT    = UIImage(named: "icon-Event-Plain")!
    let imageProfile       = UIImage(named: "icon-Profile-Placeholder")!.imageWithRenderingMode(.AlwaysTemplate)
    let imagePlaceholder   = UIImage().imageWithColor(UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0 ))

    override init() {
        super.init()
        videoAsset = AVAsset(URL: NSURL(string: videoURL)!)
        playerItem = AVPlayerItem(asset: videoAsset!)
        player = AVPlayer(playerItem: playerItem!)
        player!.actionAtItemEnd = .None
        player!.muted = true
        
        numberFormatter.numberStyle = .DecimalStyle
        numberFormatter.locale = NSLocale.currentLocale()
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.groupingSeparator = ","
        
        let pgSize = NSUserDefaults.standardUserDefaults().integerForKey("pageSize")
        if pgSize > 100 {
            pageSize = pgSize
        }
    }
    
    func colorForCategory(category: String!) -> UIColor! {
        var color = UIColor()
        if category == "eat"    { color = colorEat    }
        if category == "move"   { color = colorMove   }
        if category == "heal"   { color = colorHeal   }
        if category == "event"  { color = colorEvent  }
        if category == "online" { color = colorOnline }
        return color
    }
    
    func imageForCategory(category: String!) -> UIImage! {
        var image = UIImage()
        if category == "eat"    { image = imagePlainEAT   }
        if category == "move"   { image = imagePlainMOVE  }
        if category == "heal"   { image = imagePlainHEAL  }
        if category == "online" { image = imagePlainWEB   }
        if category == "event"  { image = imagePlainEVENT }
        return image
    }
    
    func iconImageForSlider(category: String) -> UIImage! {
        var image = UIImage()
        if category == "eat"    { image = iconSlideEat    }
        if category == "move"   { image = iconSlideMove   }
        if category == "heal"   { image = iconSlideHeal   }
        if category == "event"  { image = iconSlideEvent  }
        if category == "online" { image = iconSlideOnline }
        return image
    }
    
    func currentTime() -> String {
        let hour = NSCalendar.currentCalendar().component(.Hour, fromDate: NSDate())
        switch hour {
        case 5..<12  :
            time = .morning
        case 12..<17 :
            time = .afternoon
        case 17..<23 :
            time = .evening
        default:
            time = .night
        }
        return time.rawValue
    }
    
    func parseURL(website: String) -> String {
        var url = ""
        if website != "" && website != "http://" && website != "NULL"{
            url = website
            url = website.stringByReplacingOccurrencesOfString("http://", withString: "").stringByReplacingOccurrencesOfString("www.", withString: "").stringByReplacingOccurrencesOfString("/", withString: "")
        }
        return url
    }
    
    func categoryImageURL(category: String) -> String {
        var URL = ""
        if category == "eat"    { URL = imageEatURL  }
        if category == "move"   { URL = imageMoveURL }
        if category == "heal"   { URL = imageHealURL }
        if category == "event"  { URL = imageEatURL  }
        if category == "online" { URL = imageEatURL  }
        return URL
    }
    
    func rate(rating: Double) -> Rate {
        var rate: Rate = .Rate00
        if rating == 0.0 { rate = .Rate00 }
        if rating > 0.0 && rating <= 0.5 { rate = .Rate05 }
        if rating > 0.5 && rating <= 1.0 { rate = .Rate10 }
        if rating > 1.0 && rating <= 1.5 { rate = .Rate15 }
        if rating > 1.5 && rating <= 2.0 { rate = .Rate20 }
        if rating > 2.0 && rating <= 2.5 { rate = .Rate25 }
        if rating > 2.5 && rating <= 3.0 { rate = .Rate30 }
        if rating > 3.0 && rating <= 3.5 { rate = .Rate35 }
        if rating > 3.5 && rating <= 4.0 { rate = .Rate40 }
        if rating > 4.0 && rating <= 4.5 { rate = .Rate45 }
        if rating > 4.5 && rating <= 5.0 { rate = .Rate50 }
        return rate
    }
    
    func cost(amount: Int) -> Cost {
        var cost: Cost = .Cost0
        if amount == 0 { cost = .Cost0 }
        if amount == 1 { cost = .Cost1 }
        if amount == 2 { cost = .Cost2 }
        if amount == 3 { cost = .Cost3 }
        if amount == 4 { cost = .Cost4 }
        if amount == 5 { cost = .Cost5 }
        return cost
    }
    
    func heightForView(text: String, font: UIFont, width: CGFloat) -> CGFloat {
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        print(label.frame.height)
        return label.frame.height
    }
    
}
