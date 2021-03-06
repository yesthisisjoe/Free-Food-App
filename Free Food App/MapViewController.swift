//
//  MapViewController.swift
//  Free Food App
//
//  Created by Joe Peplowski on 2015-05-04.
//  Copyright (c) 2015 Joseph Peplowski. All rights reserved.
//

import UIKit
import MapKit
import Parse

class MapViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate, SettingsViewDelegate, UIGestureRecognizerDelegate, NewPostFormViewControllerDelegate, PostViewControllerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    
    @IBOutlet weak var locationToolbar: UIToolbar!
    @IBOutlet weak var buttonsToolbar: UIToolbar!
    @IBOutlet weak var backgroundToolbar: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var settingsButton: UIBarButtonItem!
    @IBOutlet weak var linkButton: UIBarButtonItem!
    @IBOutlet weak var newPostButton: UIBarButtonItem!
    
    @IBOutlet weak var progressViewTop: UIProgressView!
    @IBOutlet weak var progressViewBottom: UIProgressView!
    
    @IBOutlet weak var instructionsLabel: UILabel!
    
    @IBOutlet weak var cancelToolbar: UIToolbar!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    
    var screenSize: CGRect = UIScreen.mainScreen().bounds
    var statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
    var refresher: UIRefreshControl! //pull to refresh
    var flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
    var listActive = false //keeps track of when the list view is active
    var newPostAnywhereActive = false //keeps track of when the user is in the hold to post mode
    var fadingInstructions = false //keeps track of when the instructions label is being faded
    var tapAndHoldActive = false //keeps track of when the user is zoomed in enough to tap & hold
    var confirmPostLocationActive = false //keeps track of when the user is confirming that a pin is correct
    var newCoordinate: CLLocationCoordinate2D! //these are the coordinates of a post created when we tap & hold
    var newAnnotation: MKPointAnnotation! //stores the last annotation so we can remove it
    var postToPass: Post! //the post that the user tapped and to show in post view
    var posts = [Post]()
    var votes = [Vote]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        map.delegate = self

        //location button setup
        //add buttons & flexible space
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .Refresh, target: self, action: #selector(MapViewController.reloadPosts))
        refreshButton.tintColor = UIColor(red: 65/255, green: 122/255, blue: 198/255, alpha: 1)
        let trackingButton = MKUserTrackingBarButtonItem(mapView: self.map)
        trackingButton.customView!.tintColor = UIColor(red: 65/255, green: 122/255, blue: 198/255, alpha: 1)
        self.toolbarItems = [refreshButton, flexibleSpace, trackingButton]
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
        
        //set font of link & cancel buttons
        guard let font = UIFont(name: "AvenirNext-Bold", size: 18)
            else { NSLog("Error getting font for buttons."); return }
        
        linkButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        cancelButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        
        //creates pull to refresh for the table
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: #selector(MapViewController.reloadPosts), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
        
        //recognize the drag gesture on the toolbar
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(MapViewController.wasDragged(_:)))
        buttonsToolbar.addGestureRecognizer(gesture)
        buttonsToolbar.userInteractionEnabled = true
        
        reloadPosts() //initial loading of posts
        
        //create the gestures that we will recognize on the map
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(MapViewController.checkZoomGesture(_:)))
        pinch.delegate = self
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.longPress(_:)))
        uilpgr.minimumPressDuration = 0.5
        
        //add these gestures
        map.addGestureRecognizer(pinch)
        map.addGestureRecognizer(uilpgr)
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        checkZoom()
    }
    
    class CustomPointAnnotation: MKPointAnnotation {
        var post: Post!
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation) {
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if (pinView == nil) {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.animatesDrop = true
            pinView!.rightCalloutAccessoryView = UIButton(type: UIButtonType.InfoDark)
            
            //color pin based on what food type it is
            if let customAnnotation = annotation as? CustomPointAnnotation {
                if (customAnnotation.post.type == "free") {
                    pinView!.pinTintColor = UIColor.blueColor()
                } else if (customAnnotation.post.type == "cheap") {
                    pinView!.pinTintColor = UIColor.redColor()
                } else {
                    pinView!.pinTintColor = UIColor.whiteColor()
                    NSLog("error couloring pin")
                }
                
                let statusImage = UIImageView(frame: CGRectMake(0, 0, 50, 50))
                
                switch customAnnotation.post.status {
                case 0:
                    statusImage.image = UIImage(named: "Help Filled-50.png")
                case 1:
                    statusImage.image = UIImage(named: "Good Quality Filled-50.png")
                case 2:
                    statusImage.image = UIImage(named: "Poor Quality Filled-50.png")
                case 3:
                    statusImage.image = UIImage(named: "Help Filled-50.png")
                default:
                    NSLog("Unknown status code for post.")
                }
                
                pinView!.leftCalloutAccessoryView = statusImage
            } else {
                pinView!.pinTintColor = UIColor.whiteColor()
                NSLog("couldn't set pin color")
            }
        } else {
            //set up annotation
            if let customAnnotation = annotation as? CustomPointAnnotation {
                pinView!.annotation = customAnnotation
            } else {
                pinView!.annotation = annotation
            }
        }
        
        return pinView
    }
    
    //if we tap the button on an annotation callout, go to that posts' post view
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            guard let cpa = view.annotation as? CustomPointAnnotation
                else { NSLog("Error retreiving custom point annotation."); return }
            self.postToPass = cpa.post
            self.performSegueWithIdentifier("postViewSegue", sender: self)
        }
        
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func checkZoomGesture(gestureRecognizer: UIGestureRecognizer) {
        checkZoom()
    }
    
    //when we are creating a new post, this decides if we are precise enough to post
    func checkZoom(){
        if self.newPostAnywhereActive && !self.confirmPostLocationActive {
            if self.map.region.span.latitudeDelta > 0.0025 {
                if self.instructionsLabel.text != "Zoom in closer to the location of your post" && fadingInstructions == false {
                    changeInstructionLabel("Zoom in closer to the location of your post")
                    tapAndHoldActive = false
                }
            } else {
                if self.instructionsLabel.text != "Tap and hold to mark a location" && fadingInstructions == false {
                    changeInstructionLabel("Tap and hold to mark a location")
                    tapAndHoldActive = true
                }
            }
        }
    }
    
    //creates a new annotation and asks the user to confirm the location
    func createAnnotationAndConfirm(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        map.addAnnotation(annotation)
        self.newAnnotation = annotation
        
        //if we are too far away, zoom in, otherwise just center on the coordinate
        if map.region.span.latitudeDelta > 0.0025 {
            map.setRegion(MKCoordinateRegionMake(coordinate, MKCoordinateSpanMake(0.0018, 0.0018)), animated: true)
        } else {
            map.setCenterCoordinate(coordinate, animated: true)
        }
        
        let createPostHere = UIAlertController(title: nil, message: "Create your post here?", preferredStyle: .ActionSheet)
        
        //create new post here, go to new post form
        let yesAction = UIAlertAction(title: "Yes", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.confirmPostLocationActive = false
            self.performSegueWithIdentifier("newPost", sender: self)
        })
        
        //don't create new post here, remove annotation
        let noAction = UIAlertAction(title: "No", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            self.confirmPostLocationActive = false
            self.map.removeAnnotation(self.newAnnotation)
            self.newPostAnywhere()
        })
        
        createPostHere.addAction(yesAction)
        createPostHere.addAction(noAction)
        
        self.confirmPostLocationActive = true
        self.presentViewController(createPostHere, animated: true, completion: nil)
    }
    
    func longPress(gestureRecognizer: UIGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            if tapAndHoldActive {
                //create an annotation under the pressed area, center the map there
                let touchPoint = gestureRecognizer.locationInView(self.map)
                let newCoordinate: CLLocationCoordinate2D = map.convertPoint(touchPoint, toCoordinateFromView: self.map)

                hideInstructionLabel()
                createAnnotationAndConfirm(newCoordinate)
            }
        }
    }
    
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
        let tableCell:postTableCell = self.tableView.dequeueReusableCellWithIdentifier("tableCell") as! postTableCell
        
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
        
        //sets image based on post's status
        switch posts[indexPath.row].status {
        case 0:
            tableCell.statusImage.image = UIImage(named: "Help Filled-50.png")
        case 1:
            tableCell.statusImage.image = UIImage(named: "Good Quality Filled-50.png")
        case 2:
            tableCell.statusImage.image = UIImage(named: "Poor Quality Filled-50.png")
        case 3:
            tableCell.statusImage.image = UIImage(named: "Help Filled-50.png")
        default:
            NSLog("Unknown status code for post.")
        }
        
        return tableCell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.postToPass = posts[indexPath.row]
        self.performSegueWithIdentifier("postViewSegue", sender: self)
    }
    
    //called when the first view appears
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    //go to settings
    @IBAction func settingsButton(sender: AnyObject) {
        performSegueWithIdentifier("settings", sender: self)
    }
    
    //when we hit the new post button we decide if we want to add at our location or on the map
    @IBAction func newPost(sender: AnyObject) {
        let newPostMenu = UIAlertController(title: nil, message: "Where would you like to create a new post?", preferredStyle: .ActionSheet)
        
        //user wants to make a post at their location
        let myLocationAction = UIAlertAction(title: "At my Location", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            //go to map mode if we are in list mode
            if self.listActive {
                self.toolbarDown()
            }
            
            //TODO check for location permission here
            let location = SharedUserLocation.locationManager.location!.coordinate
            self.createAnnotationAndConfirm(location)
        })
        
        //user wants to find a location on the map for a new post
        let onMapAction = UIAlertAction(title: "Find on Map", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            //go to map mode if we are in list mode
            if self.listActive {
                self.toolbarDown()
            }
            self.newPostAnywhere()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        
        newPostMenu.addAction(myLocationAction)
        newPostMenu.addAction(onMapAction)
        newPostMenu.addAction(cancelAction)
        
        self.presentViewController(newPostMenu, animated: true, completion: nil)
    }
    
    func newPostAnywhere(){
        self.newPostAnywhereActive = true
        checkZoom()
        
        if self.cancelToolbar.hidden {
            switchToolbars(self.buttonsToolbar, to: self.cancelToolbar)
        }
    }
    
    //cancels the interface mode where we create a new post
    @IBAction func cancelButton(sender: AnyObject) {
        self.newPostAnywhereActive = false
        self.tapAndHoldActive = false
        
        hideInstructionLabel()
        switchToolbars(self.cancelToolbar, to: self.buttonsToolbar)
    }
    
    //this function animates fading out a toolbar and replacing it with another
    func switchToolbars(from: UIToolbar, to: UIToolbar) {
        to.alpha = 0
        to.hidden = false
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            from.alpha = 0
            }, completion: { (Bool) -> Void in
                UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    to.alpha = 1
                    }, completion: { (Bool) -> Void in
                        from.hidden = true
                        from.alpha = 1
                })
        })
    }
    
    //fade the instructions label when it changes text
    func changeInstructionLabel(instruction: String){
        //we are fading in for the first time, not chaning the text
        if self.instructionsLabel.hidden || self.instructionsLabel.alpha == 0 {
            showInstructionLabel(instruction)
        } else {
            UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.fadingInstructions = true
                self.instructionsLabel.alpha = 0
                }, completion: { (Bool) -> Void in
                    self.instructionsLabel.text = instruction
                    UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                        self.instructionsLabel.alpha = 1
                        }, completion: { (Bool) -> Void in
                            self.fadingInstructions = false
                        })
            })
        }
    }
    
    func hideInstructionLabel(){
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.fadingInstructions = true
            self.instructionsLabel.alpha = 0
            
            }, completion: { (Bool) -> Void in
                self.fadingInstructions = false
                self.instructionsLabel.hidden = true
                self.instructionsLabel.text = "placeholder"
        })
    }
    
    func showInstructionLabel(instruction: String){
        self.instructionsLabel.text = instruction
        self.instructionsLabel.hidden = false
        
        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            self.fadingInstructions = true
            self.instructionsLabel.alpha = 1
            }, completion: { (Bool) -> Void in
            self.fadingInstructions = false
        })
    }
    
    //used to switch between map & list view
    @IBAction func linkButton(sender: AnyObject) {
        listActive ? toolbarDown() : toolbarUp()
        /*
        if listActive { //we transition from map view to list view
            toolbarDown()
        } else { //we transition from list view to map view
            toolbarUp()

        }*/
    }
    
    //animates the toolbar up (map->list)
    func toolbarUp() {
        UIView.animateWithDuration(0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
            //pull up the list & toolbar
            self.buttonsToolbar.frame.origin = CGPointMake(0, self.statusBarHeight)
            self.backgroundToolbar.frame = CGRectMake(0, 0, self.buttonsToolbar.frame.width, self.buttonsToolbar.frame.height + self.statusBarHeight)
            self.tableView.frame = CGRectMake(0, self.backgroundToolbar.frame.height, self.buttonsToolbar.frame.width, self.screenSize.height - self.backgroundToolbar.frame.height)
            
            self.linkButton.title = "Map" //change button text to map
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
            
            self.linkButton.title = "List" //change button text to list
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
        progressView = listActive ? progressViewBottom : progressViewTop
        
        /*
        if listActive {
            progressView = progressViewBottom
        } else {
            progressView = progressViewTop
        }*/
        
        progressView.alpha = 1.0
        progressView.setProgress(0.5, animated: true)
        
        //parse query
        parseQueries({
            (success:Bool) -> Void in
            
            //attach votes to posts
            for index in 0..<self.posts.count {
                for vote in self.votes {
                    if self.posts[index].id == vote.postId {
                        self.posts[index].votes.append(vote)
                    }
                }
            }
            
            //decides the order of the posts in list view
            self.posts.sortInPlace({$0.status > $1.status})
            
            self.populateMap()
            self.tableView.reloadData()
            
            self.refresher.endRefreshing() //ends pull to refresh spinner
            
            
            progressView.setProgress(1, animated: true)
            _ = NSTimer.scheduledTimerWithTimeInterval(0.55, target: self, selector: #selector(MapViewController.resetRefresh), userInfo: nil, repeats: false)
        })
    }
    
    func parseQueries(completionHandler:(success:Bool) -> Void) {
        let postsQuery = PFQuery(className: "Posts")
        postsQuery.findObjectsInBackgroundWithBlock {
            (currentPosts: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil && currentPosts != nil {
                
                //no error and post isn't empty
                self.posts.removeAll(keepCapacity: true) //erase old array of posts
                
                guard let currentPosts = currentPosts as? [PFObject]
                    else { NSLog("Could not get current posts as PFObjects"); return }
                
                for post in currentPosts {
                    //create a post object from Parse then append it
                    if ((NSUserDefaults.standardUserDefaults().boolForKey("onlyFree") == false || post["FoodType"] as! String == "free")) { //check if user wants only free food
                        let toAppend = Post(
                            id: post.objectId!,
                            title: post["Title"] as! String,
                            description: post["Description"] as! String,
                            type: post["FoodType"] as! String,
                            posted: post.createdAt!,
                            confirmed: post["LastConfirmed"] as! NSDate,
                            latitude: post["Latitude"] as! Double,
                            longitude: post["Longitude"] as! Double,
                            status: post["Status"] as! Int,
                            price: post["Price"] as! String
                        )
                        self.posts.append(toAppend)
                    }
                }
                
                let votesQuery = PFQuery(className: "Votes")
                votesQuery.orderByDescending("createdAt")
                
                votesQuery.findObjectsInBackgroundWithBlock({
                    (currentVotes: [AnyObject]?, error: NSError?) -> Void in
                    if error == nil && currentVotes != nil {
                        
                        //no error and votes isn't empty
                        self.votes.removeAll(keepCapacity: true) //erase old array of posts
                        
                        guard let currentVotes = currentVotes as? [PFObject]
                            else { "Error getting current votes as PFObjects."; return }
                        
                        for vote in currentVotes {
                            //create a post object from Parse then append it
                            let toAppend = Vote(
                                id: vote.objectId!,
                                postId: vote["PostID"] as! String,
                                confirm: vote["Confirm"] as! Bool,
                                posted: vote.createdAt!,
                                userId: vote["UserID"] as! String)
                            
                            self.votes.append(toAppend)
                        }
                        
                        completionHandler(success: true)
                    } else {
                        //give an alert that there was an error loading votes
                        let alert = UIAlertController(title: "Error Retrieving Votes", message: "Could not download vote data from server. Please check your internet connection.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        
                        NSLog("error retrieving votes from Parse")
                        completionHandler(success: false)
                    }
                })
            } else {
                //give an alert that there was an error loading posts
                let alert = UIAlertController(title: "Error Retrieving Posts", message: "Could not download posts from server. Please check your internet connection.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                
                NSLog("error retrieving posts from Parse")
                completionHandler(success: false)
            }
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
            let annotation = CustomPointAnnotation()
            let latitude:CLLocationDegrees = post.latitude
            let longitude:CLLocationDegrees = post.longitude
            annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
            annotation.title = post.title
            annotation.subtitle = "Last seen \(dateSimplifier(post.confirmed))"
            annotation.post = post
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
    //check if user has authorized location services
        let status:CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        if (status == CLAuthorizationStatus.Denied || status == CLAuthorizationStatus.NotDetermined || status == CLAuthorizationStatus.Restricted) {
            NSLog("location services denied")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "settings") {
            //used in settings view controller
            let nc = segue.destinationViewController as! UINavigationController
            let vc = nc.topViewController as! SettingsViewController
            
            //pass some variables to the settings view controller before it opens
            vc.settingsChanged = false
            vc.initialOnlyFree = (NSUserDefaults.standardUserDefaults().boolForKey("onlyFree"))
            vc.delegate = self
        } else if (segue.identifier == "newPost") {
            //used in new post view controller
            let nc = segue.destinationViewController as! UINavigationController
            let vc = nc.topViewController as! NewPostFormViewController
            
            //pass values to new post controller
            vc.newPostLat = self.newAnnotation.coordinate.latitude
            vc.newPostLon = self.newAnnotation.coordinate.longitude
            vc.delegate = self
        } else if (segue.identifier == "postViewSegue") {
            //used in post view
            let nc = segue.destinationViewController as! UINavigationController
            let vc = nc.topViewController as! PostViewController
            
            //pass post to post view controller
            vc.post = self.postToPass
            vc.delegate = self
        }
    }
    
    //reload posts if we changed settings in the settings VC
    func editSettingsDidFinish(settingsChanged:Bool) {
        if (settingsChanged) {
            self.reloadPosts()
        }
    }
    
    //this method is called when we close the new post form either by cancelling or submitting it
    func finishedWith(button: String) {
        if button == "Cancel" {
            self.map.removeAnnotation(newAnnotation)
            self.newPostAnywhere()
            
        } else if button == "Submit" {
            //success submitting, notify of approval
            let alert = UIAlertController(title: "Post Submitted!", message: "Thanks for your contribution!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
            //reset state to default
            hideInstructionLabel()
            switchToolbars(self.cancelToolbar, to: self.buttonsToolbar)
            self.newPostAnywhereActive = false
            self.tapAndHoldActive = false
            
            self.reloadPosts()
        }
    }
    
    func postViewDidFinish(controller: PostViewController, changed: Bool) {
        if (changed) {
            self.reloadPosts() //TODO do you have to reload this?
        }
    }
}
