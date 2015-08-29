//
//  PostViewController.swift
//  Free Food App
//
//  Created by Joe Peplowski on 2015-08-29.
//  Copyright © 2015 Joseph Peplowski. All rights reserved.
//

import UIKit
import MapKit

class PostViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var postTableView: UITableView!
    @IBOutlet weak var map: MKMapView!
    
    var post = Post!()
    var dataSourceArray = []
    
    override func viewDidLoad() {
        //populate fields of table
        dataSourceArray = [post.title, post.description, post.type, dateSimplifier(post.confirmed), dateSimplifier(post.posted), String(post.rating), String(post.price)]
        
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
        
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        return cell!
    }
}