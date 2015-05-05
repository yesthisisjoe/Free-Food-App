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
-Add list view
-Add new post form
-Add settings page
-Check layour on all devices
*/

import UIKit
import MapKit
import CoreLocation
import Parse

class ViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var locationToolbar: UIToolbar!
    @IBOutlet weak var buttonsToolbar: UIToolbar!
    @IBOutlet weak var tableView: UITableView!
    
    
    var locationManager = CLLocationManager()
    var posts = [Post]() //TODO: this should definitely be in a different file
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.requestWhenInUseAuthorization()

        //location button setup
        //add button & flexible space
        var flexibleSpace = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
        var trackingButton = MKUserTrackingBarButtonItem(mapView: self.map)
        self.toolbarItems = [flexibleSpace, trackingButton]
        locationToolbar.setItems(toolbarItems, animated: true)
        
        //make the toolbar transparent
        self.locationToolbar.setBackgroundImage(UIImage(),
            forToolbarPosition: UIBarPosition.Any,
            barMetrics: UIBarMetrics.Default)
        self.locationToolbar.setShadowImage(UIImage(),
            forToolbarPosition: UIBarPosition.Any)
        
        reloadPosts()
    }
    
    @IBAction func reloadButton(sender: AnyObject) {
        reloadPosts()
    }
    
    //when we hit the new post button we decide if we want to add at our location or on the map
    @IBAction func newPost(sender: AnyObject) {
        let newPostMenu = UIAlertController(title: nil, message: "Where would you like to create a new post?", preferredStyle: .ActionSheet)
        
        let myLocationAction = UIAlertAction(title: "At my Location", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            println("my location!")
            //TODO: check for location services
        })
        let onMapAction = UIAlertAction(title: "Find on Map", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            println("on map!")
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            println("cancelled!")
        })
        
        newPostMenu.addAction(myLocationAction)
        newPostMenu.addAction(onMapAction)
        newPostMenu.addAction(cancelAction)
        
        self.presentViewController(newPostMenu, animated: true, completion: nil)
    }
    
    
    @IBAction func linkButton(sender: AnyObject) {
        buttonsToolbar.frame.origin = CGPointMake(0, 0)
        tableView.frame.origin = CGPointMake(0, buttonsToolbar.frame.height)
    }
    
    
    //reloads the arrays of posts
    func reloadPosts() {
        var query = PFQuery(className: "Posts")
        query.findObjectsInBackgroundWithBlock {
            (currentPosts: [AnyObject]?, error: NSError?) -> Void in
            
            
            if error == nil && currentPosts != nil {
                //no error and post isn't empty
                self.posts.removeAll(keepCapacity: true) //erase old array of posts
                
                if let currentPosts = currentPosts as? [PFObject]{
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
                print("successfully downloaded posts from Parse\n")
                self.populateMap()
            } else {
                print("error retrieving posts from Parse")//TODO: make this an error message
            }
        }
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
        print("finished populating map\n")
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
        print("map centered\n")
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

