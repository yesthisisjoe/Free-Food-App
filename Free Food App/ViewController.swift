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
    var locationManager = CLLocationManager()
    var posts = [Post]() //this should definitely be in a different file
    
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
        
        //setup to create initial location of map
        var latitude:CLLocationDegrees = 40.7
        var longitude:CLLocationDegrees = -73.9
        var location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        var latDelta:CLLocationDegrees = 0.01
        var lonDelta:CLLocationDegrees = 0.01
        var span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        
        var region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        map.setRegion(region, animated: true)
        
        
        //creates a test annotation
        var annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "Test Annotation"
        annotation.subtitle = "What a great test!"
        map.addAnnotation(annotation)
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
                        var toAppend = Post(id: <#String#>, title: <#String#>, description: <#String#>, type: <#String#>, created: <#NSDate#>, confirmed: <#NSDate#>, latitude: <#Double#>, longitude: <#Double#>, rating: <#Int#>)
                        self.posts.append(toAppend)
                    }
                }
            } else {
                print("error retrieving posts from Parse")
            }
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

