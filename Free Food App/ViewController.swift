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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.requestWhenInUseAuthorization()

        //location button setup
        //add button & flexible space
        var trackingButton = MKUserTrackingBarButtonItem(mapView: self.map)
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
        buttonsToolbar.setTranslatesAutoresizingMaskIntoConstraints(true)
        backgroundToolbar.setTranslatesAutoresizingMaskIntoConstraints(true)
        tableView.setTranslatesAutoresizingMaskIntoConstraints(true)
        
        buttonsToolbar.frame = CGRectMake(0, screenSize.height - buttonsToolbar.frame.height, screenSize.width, buttonsToolbar.frame.height)
        backgroundToolbar.frame = CGRectMake(0, screenSize.height - buttonsToolbar.frame.height, buttonsToolbar.frame.width, buttonsToolbar.frame.height)
        tableView.frame = CGRectMake(0, screenSize.height, screenSize.width, 0)
        
        //creates pull to refresh for the table
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: "reloadPosts", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
        
        //recognize the drag gesture on the toolbar
        var gesture = UIPanGestureRecognizer(target: self, action: Selector("wasDragged:"))
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
    
    //populates each cell of the table
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = posts[indexPath.row].title
        cell.detailTextLabel?.text = posts[indexPath.row].description
        return cell
    }
    
    //called when the first view appears
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
    }
    
    @IBAction func reloadButton(sender: AnyObject) {
        reloadPosts()
    }
    
    //when we hit the new post button we decide if we want to add at our location or on the map
    @IBAction func newPost(sender: AnyObject) {
        let newPostMenu = UIAlertController(title: nil, message: "Where would you like to create a new post?", preferredStyle: .ActionSheet)
        
        let myLocationAction = UIAlertAction(title: "At my Location", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            //TODO: check for location services
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
        var query = PFQuery(className: "Posts")
        query.findObjectsInBackgroundWithBlock {
            (currentPosts: [AnyObject]?, error: NSError?) -> Void in
            
            
            if error == nil && currentPosts != nil {
                //no error and post isn't empty
                self.posts.removeAll(keepCapacity: true) //erase old array of posts
                
                if let currentPosts = currentPosts as? [PFObject]{
                    let max = currentPosts.count
                    
                    for post in currentPosts {
                        //create a post object from Parse then append it
                        var toAppend = Post(
                            id: post.objectId!,
                            title: post["Title"] as! String,
                            description: post["Description"] as! String,
                            type: post["FoodType"] as! String,
                            created: post.createdAt!,
                            confirmed: post["LastConfirmed"] as! NSDate,
                            latitude: post["Latitude"] as! Double,
                            longitude: post["Longitude"] as! Double,
                            rating: post["Rating"] as! Int
                        )
                        self.posts.append(toAppend)
                    }
                }
                self.populateMap()
                self.tableView.reloadData()
            } else {
                //give an alert that there was an error loading posts
                var alert = UIAlertController(title: "Error Retrieving Posts", message: "Could not download posts from server. Please check your internet connection.", preferredStyle: UIAlertControllerStyle.Alert)
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
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.55, target: self, selector: Selector("resetRefresh"), userInfo: nil, repeats: false)
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
            //creates a test annotation
            var annotation = MKPointAnnotation()
            var latitude:CLLocationDegrees = post.latitude
            var longitude:CLLocationDegrees = post.longitude
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
            var firstPost = posts[0]
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
            var centerLat = (maxLat + minLat) / 2
            var centerLon = (maxLon + minLon) / 2
            var deltaLat = abs(maxLat - minLat) * 1.5
            var deltaLon = abs(maxLon - minLon) * 1.5
            
            //set the new region
            var latitude:CLLocationDegrees = centerLat
            var longitude:CLLocationDegrees = centerLon
            var location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
            
            var latDelta:CLLocationDegrees = deltaLat
            var lonDelta:CLLocationDegrees = deltaLon
            var span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
            
            var region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
            map.setRegion(region, animated: true)
        }
    }
    
    func mapViewWillStartLocatingUser(map: MKMapView!) {
    //deal with what happens when the user hasn't authorized sharing location
        print("hey!")
        
        var status:CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        if (status == CLAuthorizationStatus.Denied || status == CLAuthorizationStatus.NotDetermined || status == CLAuthorizationStatus.Restricted) {
            print("hey")
        } else {
            print("all good")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

