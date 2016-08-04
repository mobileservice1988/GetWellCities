//
//  FilterViewController.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import UIKit

class FilterViewController: UITableViewController {
    
    let sharedUI = UIManager.sharedManager
    var filters: [String] = []
    
    @IBOutlet weak var imageEat: UIImageView!
    @IBOutlet weak var imageMove: UIImageView!
    @IBOutlet weak var imageHeal: UIImageView!
    
    @IBOutlet weak var labelEat: UILabel!
    @IBOutlet weak var labelMove: UILabel!
    @IBOutlet weak var labelHeal: UILabel!
    
    @IBOutlet weak var switchEat: UISwitch!
    @IBOutlet weak var switchMove: UISwitch!
    @IBOutlet weak var switchHeal: UISwitch!
    
    @IBOutlet weak var stepperPrice: UIStepper!
    @IBOutlet weak var stepperRating: UIStepper!
    
    @IBOutlet weak var imgCost1: UIImageView!
    @IBOutlet weak var imgCost2: UIImageView!
    @IBOutlet weak var imgCost3: UIImageView!
    @IBOutlet weak var imgCost4: UIImageView!
    @IBOutlet weak var imgCost5: UIImageView!
    @IBOutlet weak var imgRating3: UIImageView!
    @IBOutlet weak var imgRating1: UIImageView!
    @IBOutlet weak var imgRating2: UIImageView!
    @IBOutlet weak var imgRating4: UIImageView!
    @IBOutlet weak var imgRating5: UIImageView!
    
    var currentCost : Int = 0;
    var currentRating : Double = 0;
    
    @IBAction func pricingSteppherChanged(sender: UIStepper) {
        currentCost = Int(sender.value);
        displayCost(currentCost)
        NSUserDefaults.standardUserDefaults().setInteger(currentCost, forKey: "currentCost")
    }
    @IBAction func ratingStepperChanged(sender: UIStepper) {
        currentRating = sender.value;
        displayRate(currentRating)
        NSUserDefaults.standardUserDefaults().setDouble(currentRating, forKey: "currentRating")
    }
    
    
    @IBAction func saveButtonPressed(sender: AnyObject) { updateFilters(filters) }
    @IBAction func closeButtonPressed(sender: AnyObject) { dismissFilterView() }
    
    
    @IBAction func switchValueChange(sender: AnyObject) {
        let controlSwitch = sender as! UISwitch
        performActionForSwitch(controlSwitch)
    }
    
    func performActionForSwitch(control: UISwitch) {
        if control == switchEat {
            if !switchMove.on && !switchHeal.on {
                showAlerForControl(switchEat)
            }
            else {
                NSUserDefaults.standardUserDefaults().setBool(switchEat.on, forKey:  "switchEatState")
            }
        }
        if control == switchMove {
            if !switchEat.on && !switchHeal.on {
                showAlerForControl(switchMove)
            }
            else {
                NSUserDefaults.standardUserDefaults().setBool(switchMove.on, forKey: "switchMoveState")
            }
        }
        if control == switchHeal {
            if !switchEat.on && !switchMove.on {
                showAlerForControl(switchHeal)
            }
            else {
                NSUserDefaults.standardUserDefaults().setBool(switchHeal.on, forKey: "switchHealState")
            }
        }
    }
    
    func showAlerForControl(switchControl: UISwitch) {
        let alert = UIAlertController(
            title: "Whoops.",
            message: "You have to select at least one category.",
            preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (test) -> Void in
            switchControl.setOn(true, animated: true)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageEat.tintColor  = sharedUI.colorEat
        imageMove.tintColor = sharedUI.colorMove
        imageHeal.tintColor = sharedUI.colorHeal
        labelEat.textColor  = sharedUI.colorEat
        labelMove.textColor = sharedUI.colorMove
        labelHeal.textColor = sharedUI.colorHeal
        
        imgRating1.tintColor = sharedUI.colorRate
        imgRating2.tintColor = sharedUI.colorRate
        imgRating3.tintColor = sharedUI.colorRate
        imgRating4.tintColor = sharedUI.colorRate
        imgRating5.tintColor = sharedUI.colorRate
        
        imgCost1.tintColor = sharedUI.colorCost
        imgCost2.tintColor = sharedUI.colorCost
        imgCost3.tintColor = sharedUI.colorCost
        imgCost4.tintColor = sharedUI.colorCost
        imgCost5.tintColor = sharedUI.colorCost
        
        switchEat.on = NSUserDefaults.standardUserDefaults().boolForKey("switchEatState")
        switchMove.on = NSUserDefaults.standardUserDefaults().boolForKey("switchMoveState")
        switchHeal.on = NSUserDefaults.standardUserDefaults().boolForKey("switchHealState")
        currentCost = NSUserDefaults.standardUserDefaults().integerForKey("currentCost")
        currentRating = NSUserDefaults.standardUserDefaults().doubleForKey("currentRating")
        
        displayCost(currentCost)
        displayRate(currentRating)
        
        self.stepperRating.value = currentRating
        self.stepperPrice.value = Double(currentCost)
        
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    func updateFilters(filters: [String]) {
        var defaultFilters: [String] = []
        if NSUserDefaults.standardUserDefaults().boolForKey("switchEatState")  { defaultFilters.append("eat")  }
        if NSUserDefaults.standardUserDefaults().boolForKey("switchMoveState") { defaultFilters.append("move") }
        if NSUserDefaults.standardUserDefaults().boolForKey("switchHealState") { defaultFilters.append("heal") }
        defaultFilters.append("cost:[\(currentCost)+TO+5]")
        defaultFilters.append("rating:[\(currentRating)+TO+5]")
        
        performSegueWithIdentifier("unwindToVenueListSegue", sender: defaultFilters)
    }
    
    func dismissFilterView() {
        performSegueWithIdentifier("unwindToVenueListSegue", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "unwindToVenueListSegue" {
            let controller = segue.destinationViewController as? VenueListViewController
            if sender != nil {
//                let filters = sender as! [String]
                controller?.filters = sender as! [String]
//                if filters.count < 5 {
//                    controller?.filters = sender as! [String]
//                }
//                else {
//                    controller?.filters = []
//                }
            }
        }
    }
    func displayCost(cost: Int) {
        let amount = sharedUI.cost(cost)
        switch (amount) {
        case .Cost0():
            imgCost1.image = sharedUI.imageCostEmpty
            imgCost2.image = sharedUI.imageCostEmpty
            imgCost3.image = sharedUI.imageCostEmpty
            imgCost4.image = sharedUI.imageCostEmpty
            imgCost5.image = sharedUI.imageCostEmpty
        case .Cost1():
            imgCost1.image = sharedUI.imageCostFull
            imgCost2.image = sharedUI.imageCostEmpty
            imgCost3.image = sharedUI.imageCostEmpty
            imgCost4.image = sharedUI.imageCostEmpty
            imgCost5.image = sharedUI.imageCostEmpty
        case .Cost2():
            imgCost1.image = sharedUI.imageCostFull
            imgCost2.image = sharedUI.imageCostFull
            imgCost3.image = sharedUI.imageCostEmpty
            imgCost4.image = sharedUI.imageCostEmpty
            imgCost5.image = sharedUI.imageCostEmpty
        case .Cost3():
            imgCost1.image = sharedUI.imageCostFull
            imgCost2.image = sharedUI.imageCostFull
            imgCost3.image = sharedUI.imageCostFull
            imgCost4.image = sharedUI.imageCostEmpty
            imgCost5.image = sharedUI.imageCostEmpty
        case .Cost4():
            imgCost1.image = sharedUI.imageCostFull
            imgCost2.image = sharedUI.imageCostFull
            imgCost3.image = sharedUI.imageCostFull
            imgCost4.image = sharedUI.imageCostFull
            imgCost5.image = sharedUI.imageCostEmpty
        case .Cost5():
            imgCost1.image = sharedUI.imageCostFull
            imgCost2.image = sharedUI.imageCostFull
            imgCost3.image = sharedUI.imageCostFull
            imgCost4.image = sharedUI.imageCostFull
            imgCost5.image = sharedUI.imageCostFull
        }
    }
    
    func displayRate(rate: Double) {
        let rating = sharedUI.rate(rate)
        switch (rating) {
        case .Rate00():
            imgRating1.image = sharedUI.imageRateEmpty
            imgRating2.image = sharedUI.imageRateEmpty
            imgRating3.image = sharedUI.imageRateEmpty
            imgRating4.image = sharedUI.imageRateEmpty
            imgRating5.image = sharedUI.imageRateEmpty
        case .Rate05():
            imgRating1.image = sharedUI.imageRateHalf
            imgRating2.image = sharedUI.imageRateEmpty
            imgRating3.image = sharedUI.imageRateEmpty
            imgRating4.image = sharedUI.imageRateEmpty
            imgRating5.image = sharedUI.imageRateEmpty
        case .Rate10():
            imgRating1.image = sharedUI.imageRateFull
            imgRating2.image = sharedUI.imageRateEmpty
            imgRating3.image = sharedUI.imageRateEmpty
            imgRating4.image = sharedUI.imageRateEmpty
            imgRating5.image = sharedUI.imageRateEmpty
        case .Rate15():
            imgRating1.image = sharedUI.imageRateFull
            imgRating2.image = sharedUI.imageRateHalf
            imgRating3.image = sharedUI.imageRateEmpty
            imgRating4.image = sharedUI.imageRateEmpty
            imgRating5.image = sharedUI.imageRateEmpty
        case .Rate20():
            imgRating1.image = sharedUI.imageRateFull
            imgRating2.image = sharedUI.imageRateFull
            imgRating3.image = sharedUI.imageRateEmpty
            imgRating4.image = sharedUI.imageRateEmpty
            imgRating5.image = sharedUI.imageRateEmpty
        case .Rate25():
            imgRating1.image = sharedUI.imageRateFull
            imgRating2.image = sharedUI.imageRateFull
            imgRating3.image = sharedUI.imageRateHalf
            imgRating4.image = sharedUI.imageRateEmpty
            imgRating5.image = sharedUI.imageRateEmpty
        case .Rate30():
            imgRating1.image = sharedUI.imageRateFull
            imgRating2.image = sharedUI.imageRateFull
            imgRating3.image = sharedUI.imageRateFull
            imgRating4.image = sharedUI.imageRateEmpty
            imgRating5.image = sharedUI.imageRateEmpty
        case .Rate35():
            imgRating1.image = sharedUI.imageRateFull
            imgRating2.image = sharedUI.imageRateFull
            imgRating3.image = sharedUI.imageRateFull
            imgRating4.image = sharedUI.imageRateHalf
            imgRating5.image = sharedUI.imageRateEmpty
        case .Rate40():
            imgRating1.image = sharedUI.imageRateFull
            imgRating2.image = sharedUI.imageRateFull
            imgRating3.image = sharedUI.imageRateFull
            imgRating4.image = sharedUI.imageRateFull
            imgRating5.image = sharedUI.imageRateEmpty
        case .Rate45():
            imgRating1.image = sharedUI.imageRateFull
            imgRating2.image = sharedUI.imageRateFull
            imgRating3.image = sharedUI.imageRateFull
            imgRating4.image = sharedUI.imageRateFull
            imgRating5.image = sharedUI.imageRateHalf
        case .Rate50():
            imgRating1.image = sharedUI.imageRateFull
            imgRating2.image = sharedUI.imageRateFull
            imgRating3.image = sharedUI.imageRateFull
            imgRating4.image = sharedUI.imageRateFull
            imgRating5.image = sharedUI.imageRateFull
        }
    }

}
