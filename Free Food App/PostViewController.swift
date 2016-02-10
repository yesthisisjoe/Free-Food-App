//
//  PostViewController.swift
//  Free Food App
//
//  Created by Joe Peplowski on 2015-08-29.
//  Copyright © 2015 Joseph Peplowski. All rights reserved.
//

import UIKit
import MapKit

class PostViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    var post = Post!()
    var dataSourceArray = []
    var delegate: PostViewControllerDelegate?
    var postChanged = true //we know to reload the map/table if something changed in this view
    
    override func viewDidLoad() {
        //populate fields of table
        dataSourceArray = [
            post.description,
            String(post.price),
            "last confirmed: \(dateSimplifier(post.confirmed))",
            "posted \(dateSimplifier(post.posted))",
            //post.title,
            post.type,
            "rating: \(String(post.rating))"
        ]
    
        self.title = post.title
        
        map.delegate = self
        
        //add post pin to map
        let annotation = MKPointAnnotation()
        let annotationLatitude:CLLocationDegrees = post.latitude
        let annotationLongitude:CLLocationDegrees = post.longitude
        annotation.coordinate = CLLocationCoordinate2DMake(annotationLatitude, annotationLongitude)
        map.addAnnotation(annotation)
        
        //set map region on coordinate
        let latitude:CLLocationDegrees = post.latitude
        let longitude:CLLocationDegrees = post.longitude
        let location:CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        let latDelta:CLLocationDegrees = 0.001
        let lonDelta:CLLocationDegrees = 0.001
        let span:MKCoordinateSpan = MKCoordinateSpanMake(latDelta, lonDelta)
        
        let region:MKCoordinateRegion = MKCoordinateRegionMake(location, span)
        map.setRegion(region, animated: true)
        
        navigationItem.setHidesBackButton(false, animated: false)
        
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backButton(sender: AnyObject) {
        delegate!.postViewDidFinish(self, changed: postChanged)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //colour pins based on their type
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        
        if (post.type == "free") {
            pinView.pinTintColor = UIColor.blueColor()
        } else if (post.type == "cheap") {
            pinView.pinTintColor = UIColor.redColor()
        } else {
            pinView.pinTintColor = UIColor.whiteColor()
            print("error couloring pin")
        }
        
        return pinView
    }
}

protocol PostViewControllerDelegate{
    func postViewDidFinish(controller: PostViewController, changed: Bool)
}