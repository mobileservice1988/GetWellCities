//
//  SearchViewController.swift
//  Copyright © 2016 Get Well Company. All rights reserved.
//

import UIKit
import RealmSwift
import Localytics

class SearchViewController: UITableViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

    let sharedAPI = APIManager.sharedManager
    let sharedStack = RealmStack.sharedStack
    
    var headerCell: HeaderTableViewCell!
    var searchController: UISearchController!
    var isSearchResults = true
    var isSttusLabelSetup = false
    weak var lblStatus : UITextView!

    lazy var visibleResults: [Venue] = []
    var searches = try! Realm().objects(Search).sorted("date", ascending: false).toArray()

    
    var showResults = false {
        didSet {
            if showResults == false {
                searches = try! Realm().objects(Search).sorted("date", ascending: false).toArray()
            }
            dispatch_async(dispatch_get_main_queue(), {
                if self.searches.count > 0 && self.isSttusLabelSetup{
                    self.removeStatusLabel()
                }
                self.tableView.reloadData()
            })
        }
    }
    
    var filterString: String? = nil {
        didSet {
            if filterString == nil || filterString!.isEmpty { }
            else {
                searchForTerm(filterString!)
            }
        }
    }
    
    func searchForTerm(term: String!) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        sharedAPI.searchForTerms(term.lowercaseString, completionHandler: { (venues) in
            Localytics.tagSearched(term, contentType: "", resultCount: venues!.count, attributes: [:])
            if venues!.count > 0 {
                let value: [String: AnyObject] = [
                    "term"    : term,
                    "count"   : venues!.count,
                    "date"    : NSDate().timeIntervalSince1970
                ]
                let realm = try! Realm()
                try! realm.write({
                    realm.create(Search.self, value: value, update: true)
                })
                self.visibleResults = venues!
                self.visibleResults.sortInPlace({ $0.score > $1.score })
                self.showResults = true
            }
            else {
                self.showAlertForTerm(term)
            }
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        })
    }

    func showAlertForTerm(term: String!) {
        dispatch_async(dispatch_get_main_queue(), {
            let alert = UIAlertController(
                title: "Whoops.",
                message: "Your search - \"\(term)\" - didn't match any places, events, or websites. Please try other search terms.",
                preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (test) -> Void in
                self.showResults = false
                self.searchController.searchBar.text = ""
                self.searchController.searchBar.becomeFirstResponder()

            }))
            self.presentViewController(alert, animated: true, completion: nil)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false

        searchController.searchBar.searchBarStyle = .Minimal
        searchController.searchBar.placeholder = NSLocalizedString("Search ...", comment: "")
        
        searchController.searchBar.autocapitalizationType = .None
        navigationItem.titleView = searchController.searchBar
        
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.searchBar.showsCancelButton = false
        definesPresentationContext = true
        
        let searchBarTextField = searchController.searchBar.valueForKey("searchField") as! UITextField
        searchBarTextField.backgroundColor = UIColor.clearColor()
        searchBarTextField.leftViewMode = .Never
        tableView.tableFooterView = UIView(frame: CGRectZero)
        
        if searches.count == 0 && visibleResults.count == 0 {
            NSLog("log");
            isSearchResults = false
            setupStatusLabel()
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationItem.hidesBackButton = true
        navigationController?.navigationBarHidden = false
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        searchController.active = true
        super.viewDidAppear(animated)
        Localytics.tagScreen("Search ")
    }
    func removeStatusLabel() {
        lblStatus.removeFromSuperview()
        lblStatus = nil
    }
    func setupStatusLabel() {
        let deviceSize = UIScreen.mainScreen().bounds.size
        lblStatus = UITextView(frame: CGRectMake(10,30,deviceSize.width - 20,100))
        lblStatus.scrollEnabled = false
        lblStatus.text = "Search for places that inspire. Your results will show up here!"
        let txtReviewWidth = deviceSize.width - 20
        lblStatus.textAlignment = .Left
        lblStatus.font = UIFont.systemFontOfSize(16)
        lblStatus.sizeThatFits(CGSize(width: txtReviewWidth, height: CGFloat.max))
        let newSize = lblStatus.sizeThatFits(CGSize(width: txtReviewWidth, height: CGFloat.max))
        var newFrame = lblStatus.frame
        newFrame.size = CGSize(width: txtReviewWidth, height: newSize.height)
        lblStatus.frame = newFrame
        lblStatus.alpha = 1
        isSttusLabelSetup = true
        self.view.addSubview(lblStatus)
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.characters.count == 0 {
            if isSearchResults  {
                showResults = false
            } else {
                if visibleResults.count == 0 {
                    lblStatus.alpha = 1
                }
                
            }
            
        } else {
            if isSearchResults == false {
                if visibleResults.count == 0 {
                    lblStatus.alpha = 0
                }                
            }
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        filterString = searchBar.text!
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func didPresentSearchController(searchController: UISearchController) {
        dispatch_async(dispatch_get_main_queue(), {
            searchController.searchBar.becomeFirstResponder()
        })
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchController.active = false
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if !showResults && searches.count > 0 {
            return 48
        }
        if visibleResults.count > 0 {
            return 48
        }
        else {
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 78
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 78
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !showResults {
            return searches.count
        }
        else {
            return visibleResults.count
        }
    }

    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        headerCell = tableView.dequeueReusableCellWithIdentifier("headerCell")! as! HeaderTableViewCell
        let separator = UIView(frame: CGRectMake(0, headerCell.frame.size.height - 0.5, headerCell.frame.size.width, 0.5))
        separator.backgroundColor = tableView.separatorColor
        headerCell.addSubview(separator)
        
        if !showResults && searches.count > 0 {
            headerCell.headerTitleLabel.text = "Search History"
            return headerCell
        }
        if visibleResults.count > 0 {
            headerCell.headerTitleLabel.text = "Search Results"
            headerCell.searchCountLabel.text = String("\(visibleResults.count) Places")
            return headerCell
        }
        else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchCell", forIndexPath: indexPath) as! SearchTableViewCell
        if !showResults {
            cell.search = searches[indexPath.row]
        }
        else {
            cell.venue = visibleResults[indexPath.row]
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)! as! SearchTableViewCell
        if  !showResults {
            searchController.searchBar.text = cell.search.term
            searchForTerm(cell.search.term)
        }
        else {
            sharedStack.checkVenue(cell.venue) { (venue) in
                self.performSegueWithIdentifier("showVenueDetailSegue", sender: venue)
            }
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showVenueDetailSegue" {
            let viewcontroller = segue.destinationViewController as? VenueDetailViewController
            viewcontroller!.venue = sender as? Venue
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
