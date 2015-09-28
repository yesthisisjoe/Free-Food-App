//
//  PostViewController.swift
//  Free Food App
//
//  Created by Joe Peplowski on 2015-08-29.
//  Copyright © 2015 Joseph Peplowski. All rights reserved.
//

import UIKit
import MapKit

class PostViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MKMapViewDelegate {
    @IBOutlet weak var postTableView: UITableView!
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    
    var post = Post!()
    var dataSourceArray = []
    var delegate: PostViewControllerDelegate?
    var postChanged = true //we know to reload the map/table if something changed in this view
    
    override func viewDidLoad() {
        //populate fields of table
        dataSourceArray = [
            post.title,
            post.type,
            "posted \(dateSimplifier(post.posted))",
            "rating: \(String(post.rating))",
            post.description,
            "last confirmed: \(dateSimplifier(post.confirmed))",
            String(post.price)
        ]
        
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceArray.count // Most of the time my data source is an array of something...  will replace with the actual name of the data source
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        cell!.textLabel!.text = (dataSourceArray[indexPath.row] as! String)
        
        switch indexPath.row {
        case 0:
            cell!.textLabel!.font = UIFont(name: "AvenirNext-Bold", size: 24)
            break
        case 1:
            cell!.textLabel!.font = UIFont(name: "BodoniSvtyTwoSCITCTT-Book", size: 18)
            break
        case 2:
            cell!.textLabel!.font = UIFont(name: "AvenirNext-Italic", size: 15)
            break
        case 3:
            cell!.textLabel!.font = UIFont(name: "AvenirNext-Italic", size: 15)
            break
        case 4:
            cell!.textLabel!.font = UIFont(name: "AvenirNext-Light", size: 15)
            break
        case 5:
            cell!.textLabel!.font = UIFont(name: "AvenirNext-Italic", size: 15)
            break
        case 6:
            cell!.textLabel!.font = UIFont(name: "AvenirNext-Italic", size: 15)
            break
        default:
            print("hit default statement setting post table view stuff")
            break
        }
        
        return cell!
    }
    
    //stretch the map when we bounce the table view
    func scrollViewDidScroll(scrollView: UIScrollView) {
        map.frame = CGRectMake(map.frame.minX, map.frame.minY, map.frame.width, 145 - self.postTableView.contentOffset.y)
    }
}

protocol PostViewControllerDelegate{
    func postViewDidFinish(controller: PostViewController, changed: Bool)
}