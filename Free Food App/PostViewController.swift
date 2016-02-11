//
//  PostViewController.swift
//  Free Food App
//
//  Created by Joe Peplowski on 2015-08-29.
//  Copyright © 2015 Joseph Peplowski. All rights reserved.
//

import UIKit
import MapKit
import Parse

class PostViewController: UIViewController, MKMapViewDelegate, UITableViewDelegate {
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet var reportMissingButton: UIButton!
    @IBOutlet var confirmPostButton: UIButton!
    @IBOutlet var priceImage: UIImageView!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var statusImage: UIImageView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet weak var votesTableView: UITableView!
    
    var post = Post!(nil)
    var delegate: PostViewControllerDelegate?
    var postChanged = true //we know to reload the map/table if something changed in this view
    
    override func viewDidLoad() {
        //set text & images so they match the post's attributes
        
        self.title = post.title
        
        if post.type == "free" {
            priceLabel.text = "Free!"
        } else {
            priceLabel.text = post.price
        }
        
        descriptionLabel.text = post.description
       
        switch post.status {
        case 0:
            statusImage.image = UIImage(named: "Help Filled-50.png")
            statusLabel.text = "Never confirmed"
            break
        case 1:
            statusImage.image = UIImage(named: "Good Quality Filled-50.png")
            statusLabel.text = "Likely still there"
            break
        case 2:
            statusImage.image = UIImage(named: "Poor Quality Filled-50.png")
            statusLabel.text = "Likely missing"
            break
        case 3:
            statusImage.image = UIImage(named: "Help Filled-50.png")
            statusLabel.text = "May be missing"
            break
        default:
            NSLog("Unknown status code for post.")
        }
        
        confirmPostButton.setTitle(" Confirm\n This Post", forState: .Normal)
        reportMissingButton.setTitle(" Report\n Missing", forState: .Normal)
        
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post.votes.count + 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let tableCell: voteTableCell = self.votesTableView.dequeueReusableCellWithIdentifier("tableCell") as! voteTableCell
                
        if indexPath.row == post.votes.count {
            tableCell.voteCellLabel.text = "\(dateSimplifier(post.posted)): posted"
            tableCell.voteCellImage.image = UIImage(named: "Clock Filled-50.png")
        } else {
            //sets image & label of vote cell
            let thisVote = post.votes[indexPath.row]
            let confirmOrReportText = thisVote.confirm ? "confirmed" : "reported missing"
            tableCell.voteCellLabel.text = "\(dateSimplifier(post.votes[indexPath.row].posted)): " + confirmOrReportText
            tableCell.voteCellImage.image = thisVote.confirm ? UIImage(named: "Good Quality Filled-50.png") : UIImage(named: "Poor Quality Filled-50.png")
        }

        return tableCell
    }
    
    @IBAction func backButton(sender: AnyObject) {
        delegate!.postViewDidFinish(self, changed: postChanged)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func confirmPostButton(sender: AnyObject) {
        sendVote(true)
    }
    
    @IBAction func reportMissingButton(sender: AnyObject) {
        sendVote(false)
    }
    
    func sendVote(confirm: Bool) {
        let vote = PFObject(className: "Votes")
        vote["Confirm"] = confirm
        vote["PostID"] = post.id
        
        vote.saveInBackgroundWithBlock( {
            (success, error) -> Void in
            if (success) {
                if confirm {
                    self.confirmPostButton.enabled = false
                } else {
                    self.reportMissingButton.enabled = false
                }
            } else {
                //failure, notify of error
                NSLog(String(error))
                let alert = UIAlertController(title: "Error Submitting Vote", message: "Could not submit your vote. Please check your internet connection and try again.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        })
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
            NSLog("error couloring pin")
        }
        
        return pinView
    }
}

protocol PostViewControllerDelegate{
    func postViewDidFinish(controller: PostViewController, changed: Bool)
}