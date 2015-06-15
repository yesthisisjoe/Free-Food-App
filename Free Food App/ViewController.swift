//
//  ViewController.swift
//  Free Food App
//
//  Created by Joe Peplowski on 2015-05-04.
//  Copyright (c) 2015 Joseph Peplowski. All rights reserved.
//

/*
TODO:
-Handle denied location sharing
-Handle in-call status bar
-If progress bar is in middle (airplane mode) and view is switched, it is on the wrong side
-Add new post form
-Add settings page
-Check layour on all devices
*/

import UIKit
import MapKit
import CoreLocation
import Parse

class ViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var locationToolbar: UIToolbar!
    @IBOutlet weak var buttonsToolbar: UIToolbar!
    @IBOutlet weak var backgroundToolbar: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    @IBOutlet weak var linkButton: UIBarButtonItem!
    @IBOutlet weak var newPostButton: UIBarButtonItem!
    @IBOutlet weak var progressViewTop: UIProgressView!
    @IBOutlet weak var progressViewBottom: UIProgressView!
    
    var locationManager = CLLocationManager()
    var screenSize: CGRect = UIScreen.mainScreen().bounds
    var statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
    var refresher: UIRefreshControl! //pull to refresh
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView() //spinner for refresh button
    var flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
    
    var posts = [Post]() //TODO: this should definitely be in a different file
    var listActive = false //keeps track of when the list view is active
    var showFree = true //tracks whether or not user wants to see free food posts
    var showCheap = true //tracks whether or not user wants to see cheap food posts
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.requestWhenInUseAuthorization()

        //location button setup
        //add button & flexible space
        let trackingButton = MKUserTrackingBarButtonItem(mapView: self.map)
        self.toolbarItems = [flexibleSpace, trackingButton]
        locationToolbar.setItems(toolbarItems, animated: true)
        
        //make the location toolbar transparent
        self.locationToolbar.setBackgroundImage(UIImage(),
            forToolbarPosition: UIBarPosition.Any,
            barMetrics: UIBarMetrics.Default)
        self.locationToolbar.setShadowImage(UIImage(),
            forToolbarPosition: UIBarPosition.Any)
        
        //buttons toolbar setup
        //make the button toolbar transparent
        self.buttonsToolbar.setBackgroundImage(UIImage(),
            forToolbarPosition: UIBarPosition.Any,
            barMetrics: UIBarMetrics.Default)
        self.buttonsToolbar.setShadowImage(UIImage(),
            forToolbarPosition: UIBarPosition.Any)
        
        //place toolbar & background on the bottom of the screen
        buttonsToolbar.translatesAutoresizingMaskIntoConstraints = true
        backgroundToolbar.translatesAutoresizingMaskIntoConstraints = true
        tableView.translatesAutoresizingMaskIntoConstraints = true
        
        buttonsToolbar.frame = CGRectMake(0, screenSize.height - buttonsToolbar.frame.height, screenSize.width, buttonsToolbar.frame.height)
        backgroundToolbar.frame = CGRectMake(0, screenSize.height - buttonsToolbar.frame.height, buttonsToolbar.frame.width, buttonsToolbar.frame.height)
        tableView.frame = CGRectMake(0, screenSize.height, screenSize.width, 0)
        
        //use this to find font names
        /*for family in UIFont.familyNames()
        {
            print("\(family)")
            for name in UIFont.fontNamesForFamilyName(family as String)
            {
                print("  \(name)")
            }
        }*/
        
        //set font of link button
        if let font = UIFont(name: "AvenirNext-Bold", size: 18) {
            linkButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        } else {
            print("error setting font of link button")
        }
        
        //creates pull to refresh for the table
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: "reloadPosts", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
        
        //recognize the drag gesture on the toolbar
        let gesture = UIPanGestureRecognizer(target: self, action: Selector("wasDragged:"))
        buttonsToolbar.addGestureRecognizer(gesture)
        //backgroundToolbar.addGestureRecognizer(gesture)
        buttonsToolbar.userInteractionEnabled = true
        //backgroundToolbar.userInteractionEnabled = true
        
        reloadPosts() //initial loading of posts
    }
    
    //sets number of rows in the table
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //if the table is empty we diplay a message
        if (posts.count > 0) {
            return 1
        } else {
            let messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
            
            messageLabel.text = "There are no food postings right now." //TODO: update this label so it checks what filters you have on, and what notifications you enabled
            messageLabel.textColor = UIColor.blackColor()
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = NSTextAlignment.Center
            messageLabel.font = UIFont(name: "AvenirNext-Italic", size: 15.0)
            messageLabel.sizeToFit()
            
            self.tableView.backgroundView = messageLabel;
            self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            
            return 0
        }
    }
    
    //populates each cell of the table
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tableCell:cell = self.tableView.dequeueReusableCellWithIdentifier("tableCell") as! cell
        var fade: CGFloat
        
        //sets up formatted string for last confirmed
        let lastConfirmed = dateSimplifier(posts[indexPath.row].confirmed)
        var boldLastConfirmed = NSMutableAttributedString()
        boldLastConfirmed = NSMutableAttributedString(string: "last confirmed: \(lastConfirmed)", attributes: [NSFontAttributeName:UIFont(name: "AvenirNext-Italic", size: 15.0)!])
        boldLastConfirmed.addAttribute(NSFontAttributeName, value: UIFont(name: "AvenirNext-DemiBoldItalic", size: 15.0)!, range: NSRange(location: 16, length: lastConfirmed.characters.count))
        
        //sets up formatted string for posted date
        let posted = dateSimplifier(posts[indexPath.row].posted)
        var boldPosted = NSMutableAttributedString()
        boldPosted = NSMutableAttributedString(string: "posted: \(posted)", attributes: [NSFontAttributeName:UIFont(name: "AvenirNext-Italic", size: 15.0)!])
        boldPosted.addAttribute(NSFontAttributeName, value: UIFont(name: "AvenirNext-DemiBoldItalic", size: 15.0)!, range: NSRange(location: 8, length: posted.characters.count))
        
        //sets up formatted string for title & type
        let title = posts[indexPath.row].title
        let type = posts[indexPath.row].type
        var boldTitle = NSMutableAttributedString()
        boldTitle = NSMutableAttributedString(string: "\(title)  \(type)", attributes: [NSFontAttributeName:UIFont(name: "AvenirNext-DemiBold", size: 18.0)!])
        boldTitle.addAttribute(NSFontAttributeName, value: UIFont(name: "BodoniSvtyTwoSCITCTT-Book", size: 18.0)!, range: NSRange(location: title.characters.count + 2, length: type.characters.count))
        if (type == "free") {
            boldTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1.0), range: NSRange(location: title.characters.count + 2, length: type.characters.count))
        } else if (type == "cheap") {
            boldTitle.addAttribute(NSForegroundColorAttributeName, value: UIColor(red: 0.0, green: 0.75, blue: 1.0, alpha: 1.0), range: NSRange(location: title.characters.count + 2, length: type.characters.count))
        }
        
        
        //sets values for strings in cells
        tableCell.titleLabel.attributedText = boldTitle
        tableCell.lastConfirmedLabel.attributedText = boldLastConfirmed
        tableCell.postedLabel.attributedText = boldPosted
        tableCell.ratingLabel.text = String(posts[indexPath.row].rating)
        
        //color cell based on rating
        if (posts[indexPath.row].rating > 0) {
            fade = min(0.2 + (CGFloat(posts[indexPath.row].rating) * 0.1), 0.9)
            //tableCell.contentView.backgroundColor = UIColor(red: fade, green: 1.0, blue: fade, alpha: 1.0)
            
            tableCell.titleLabel.alpha = 1.0
            tableCell.lastConfirmedLabel.alpha = 1.0
            tableCell.postedLabel.alpha = 1.0
            tableCell.ratingLabel.alpha = 1.0
            tableCell.ratingLabel.textColor = UIColor(red: 0.2, green: fade, blue: 0.2, alpha: 1.0)
        } else {
            fade = 0.5//max((1.0 + CGFloat(posts[indexPath.row].rating) * 0.1), 0.3)
            //tableCell.contentView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            
            //fade out text
            tableCell.titleLabel.alpha = fade
            tableCell.lastConfirmedLabel.alpha = fade
            tableCell.postedLabel.alpha = fade
            tableCell.ratingLabel.alpha = fade
            tableCell.ratingLabel.textColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        }
        
        return tableCell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        //color cell based on rating
        var _: CGFloat //this is fade. change back if you use fade
        
        if (posts[indexPath.row].rating > 0) {
            /*
            //positive rating
            fade = max((1.0 - CGFloat(posts[indexPath.row].rating) * 0.01), 0.8)
            cell.backgroundColor = UIColor(red: fade, green: 1.0, blue: fade, alpha: 1.0)
            */
        } else {
            /*
            //negative rating
            fade = max((1.0 + CGFloat(posts[indexPath.row].rating) * 0.1), 0.3)
            */
            cell.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            
            /*
            //fade out text
            cell.titleLabel.alpha = fade
            cell.lastConfirmedLabel.alpha = fade
            tableCell.ratingLabel.alpha = fade
            */
        }

    }
    
    func dateSimplifier(sinceDate: NSDate) -> String {
        let elapsedTime = Int(NSDate().timeIntervalSinceDate(sinceDate))
        var simplifiedDate = ""
        
        if (elapsedTime < 60) { //less than a minute
            simplifiedDate = "less than 1m ago"
        } else if (elapsedTime >= 60 && elapsedTime < 60*60) { //less than an hour
            simplifiedDate = "\(elapsedTime / 60)m ago"
        } else if (elapsedTime >= 60*60 && elapsedTime < 60*60*24) { //less than a day
            simplifiedDate = "\(elapsedTime / 60 / 60)h ago"
        } else { //over a day
            simplifiedDate = "\(elapsedTime / 60 / 60 / 24)d ago"
        }
        
        return simplifiedDate
    }
    
    //called when the first view appears
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    @IBAction func reloadButton(sender: AnyObject) {
        //performSegueWithIdentifier("settings", sender: self)
        reloadPosts()
    }
    
    //when we hit the new post button we decide if we want to add at our location or on the map
    @IBAction func newPost(sender: AnyObject) {
        let newPostMenu = UIAlertController(title: nil, message: "Where would you like to create a new post?", preferredStyle: .ActionSheet)
        
        let myLocationAction = UIAlertAction(title: "At my Location", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            let location = self.locationManager.location!.coordinate
            let span:MKCoordinateSpan = MKCoordinateSpanMake(0.001, 0.001)
            
            let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            self.map.setRegion(region, animated: true)
        })
        let onMapAction = UIAlertAction(title: "Find on Map", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        newPostMenu.addAction(myLocationAction)
        newPostMenu.addAction(onMapAction)
        newPostMenu.addAction(cancelAction)
        
        self.presentViewController(newPostMenu, animated: true, completion: nil)
    }
    
    @IBAction func linkButton(sender: AnyObject) {
        if !listActive { //we transition from map view to list view
            toolbarUp()
        } else { //we transition from list view to map view
            toolbarDown()
        }
    }
    
    //animates the toolbar up (map->list)
    func toolbarUp() {
        UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            //pull up the list & toolbar
            self.buttonsToolbar.frame.origin = CGPointMake(0, self.statusBarHeight)
            self.backgroundToolbar.frame = CGRectMake(0, 0, self.buttonsToolbar.frame.width, self.buttonsToolbar.frame.height + self.statusBarHeight)
            self.tableView.frame = CGRectMake(0, self.backgroundToolbar.frame.height, self.buttonsToolbar.frame.width, self.screenSize.height - self.backgroundToolbar.frame.height)
            
            self.linkButton.title = "MAP" //change button text to map
            }, completion: nil)
        listActive = true //tracks whether the list view is active
    }
    
    //animates the toolbar down (list->map)
    func toolbarDown() {
        UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            //drop down the list & toolbar
            self.buttonsToolbar.frame.origin = CGPointMake(0, self.screenSize.height - self.buttonsToolbar.frame.height)
            self.backgroundToolbar.frame = CGRectMake(0, self.screenSize.height - self.buttonsToolbar.frame.height, self.buttonsToolbar.frame.width, self.buttonsToolbar.frame.height)
            self.tableView.frame = CGRectMake(0, self.screenSize.height, self.screenSize.width, 0)
            
            self.linkButton.title = "LIST" //change button text to list
        }, completion: nil)
        
        listActive = false //tracks whether the list view is active
    }
    
    //called when we drag the toolbar around
    func wasDragged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translationInView(self.view)
        
        //moves toolbar & table while we drag it
        buttonsToolbar.center = CGPoint(
            x: buttonsToolbar.center.x,
            y: buttonsToolbar.center.y + translation.y
        )
        
        backgroundToolbar.frame = CGRect(
            x: backgroundToolbar.frame.origin.x,
            y: backgroundToolbar.frame.origin.y + translation.y + (translation.y * (statusBarHeight / screenSize.height)),
            width: backgroundToolbar.frame.width,
            height: backgroundToolbar.frame.height - (translation.y * (statusBarHeight / screenSize.height))
        )
        
        tableView.frame = CGRect(
            x: tableView.frame.origin.x,
            y: tableView.frame.origin.y + translation.y,
            width: screenSize.width,
            height: tableView.frame.height - translation.y
        )
        
        gesture.setTranslation(CGPointZero, inView: self.view) //resets gesture
        /*
        //change these variables to change the physics of moving the toolbar
        let throwingThreshold: CGFloat = 1000
        let throwingVelocityPadding: CGFloat = 35
        
        //velocity stuff
        var velocity = gesture.velocityInView(self.view)
        var magnitude = velocity.y
        
        if (magnitude > throwingThreshold) {
            var pushBehavior = UIPushBehavior(items: [buttonsToolbar, backgroundToolbar, tableView], mode: UIPushBehaviorMode.Instantaneous)
            pushBehavior.pushDirection = CGVectorMake(0, (velocity.y / 10))
            pushBehavior.magnitude = (magnitude / throwingVelocityPadding)
            
            //self.pushBehavior = pushBehavior //not sure about this one
        }
        */
        
        if gesture.state == UIGestureRecognizerState.Ended {
            if buttonsToolbar.center.y < (screenSize.height / 2) {
                //button was let go closer to top
                toolbarUp()
            } else {
                //button was let go closer to bottom
                toolbarDown()
            }
        }
    }
    
    //reloads the arrays of posts
    func reloadPosts() {
        var progressView: UIProgressView
        
        //decide which progress view to use
        if (listActive == true) {
            progressView = progressViewBottom
        } else {
            progressView = progressViewTop
        }
        
        progressView.alpha = 1.0
        progressView.setProgress(0.5, animated: true)
        //create an activity spinner
        /*activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 25, 25))
        activityIndicator.sizeToFit()
        activityIndicator.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin | UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleBottomMargin | UIViewAutoresizing.FlexibleTopMargin
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.startAnimating()
        
        //replace the refresh button with the spinner
        var loadingView = UIBarButtonItem(customView: activityIndicator)
        self.buttonsToolbar.setItems([loadingView, flexibleSpace, linkButton, flexibleSpace, newPostButton], animated: true)*/
        
        //parse query
        let query = PFQuery(className: "Posts")
        query.findObjectsInBackgroundWithBlock {
            (currentPosts: [AnyObject]?, error: NSError?) -> Void in
            
            
            if error == nil && currentPosts != nil {
                //no error and post isn't empty
                self.posts.removeAll(keepCapacity: true) //erase old array of posts
                
                if let currentPosts = currentPosts as? [PFObject]{
                    
                    for post in currentPosts {
                        //create a post object from Parse then append it
                        if ((self.showFree == true && post["FoodType"] as! String == "free") || (self.showCheap == true && post["FoodType"] as! String == "cheap")) {
                            let toAppend = Post(
                                id: post.objectId!,
                                title: post["Title"] as! String,
                                description: post["Description"] as! String,
                                type: post["FoodType"] as! String,
                                posted: post.createdAt!,
                                confirmed: post["LastConfirmed"] as! NSDate,
                                latitude: post["Latitude"] as! Double,
                                longitude: post["Longitude"] as! Double,
                                rating: post["Rating"] as! Int
                            )
                            self.posts.append(toAppend)
                        }
                    }
                }
                //decides the order of the posts in list view
                self.posts.sortInPlace({$0.rating > $1.rating})
                
                self.populateMap()
                self.tableView.reloadData()
            } else {
                //give an alert that there was an error loading posts
                let alert = UIAlertController(title: "Error Retrieving Posts", message: "Could not download posts from server. Please check your internet connection.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
                print("error retrieving posts from Parse")
            }
        //replaces activity spinner in toolbar with button
        /*self.buttonsToolbar.setItems([self.refreshButton, self.flexibleSpace, self.linkButton,
        self.flexibleSpace, self.newPostButton], animated: true)
        self.activityIndicator.stopAnimating()*/

        self.refresher.endRefreshing() //ends pull to refresh spinner
            
            
        progressView.setProgress(1, animated: true)
        _ = NSTimer.scheduledTimerWithTimeInterval(0.55, target: self, selector: Selector("resetRefresh"), userInfo: nil, repeats: false)
        }
    }
    
    //resets progress views after reload is complete
    func resetRefresh() {
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
            self.progressViewBottom.alpha = 0.0
            self.progressViewTop.alpha = 0.0
        }, completion: {
            (value: Bool) in
            self.progressViewTop.setProgress(0, animated: false)
            self.progressViewBottom.setProgress(0, animated: false)
        })
    }
    
    //places annotations on map for all downloaded posts
    func populateMap() {
        map.removeAnnotations(map.annotations)
        for post in self.posts {
            //populate map with pins from what we have downloaded
            let annotation = MKPointAnnotation()
            let latitude:CLLocationDegrees = post.latitude
            let longitude:CLLocationDegrees = post.longitude
            annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            annotation.title = post.title
            annotation.subtitle = post.description
            map.addAnnotation(annotation)
        }
        
        
        centerMap()
    }
    
    //sets the location of the map to show all pins
    func centerMap() {
        if posts.count > 0 {
            //set initial max and min values to the first member
            let firstPost = posts[0]
            var maxLat = firstPost.latitude
            var minLat = firstPost.latitude
            var maxLon = firstPost.longitude
            var minLon = firstPost.longitude
            
            //find max and min latitude and longitude
            for post in self.posts {
                if post.latitude > maxLat {maxLat = post.latitude}
                if post.latitude < minLat {minLat = post.latitude}
                if post.longitude > maxLon {maxLon = post.longitude}
                if post.longitude < minLon {minLon = post.longitude}
            }
            
            //calculate center and delta
            let centerLat = (maxLat + minLat) / 2
            let centerLon = (maxLon + minLon) / 2
            let deltaLat = abs(maxLat - minLat) * 1.5
            let deltaLon = abs(maxLon - minLon) * 1.5
            
            //set the new region
            let latitude:CLLocationDegrees = centerLat
            let longitude:CLLocationDegrees = centerLon
            let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            
            let latDelta:CLLocationDegrees = deltaLat
            let lonDelta:CLLocationDegrees = deltaLon
            let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
            
            let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            map.setRegion(region, animated: true)
        }
    }
    
    func mapViewWillStartLocatingUser(map: MKMapView) {
    //deal with what happens when the user hasn't authorized sharing location
        print("hey!", appendNewline: false)
        
        let status:CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        if (status == CLAuthorizationStatus.Denied || status == CLAuthorizationStatus.NotDetermined || status == CLAuthorizationStatus.Restricted) {
            print("hey", appendNewline: false)
        } else {
            print("all good", appendNewline: false)
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

