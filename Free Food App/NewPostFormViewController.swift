//
//  NewPostFormViewController.swift
//  Free Food App
//
//  Created by Joe Peplowski on 2015-07-05.
//  Copyright © 2015 Joseph Peplowski. All rights reserved.
//

//TODO: -format dollar sign in price
//      -generally fix up the new post form

import UIKit
import Parse

protocol NewPostFormViewControllerDelegate {
    func finishedWith(button: String)
}

class NewPostFormViewController: UITableViewController {

    @IBOutlet weak var freeOrCheapValue: UISegmentedControl!
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionPlaceholder: UITextView!
    @IBOutlet weak var descriptionField: UITextView!
    
    var delegate: NewPostFormViewControllerDelegate! = nil
    var newPostLat: Double?
    var newPostLon: Double?
    var foodType = "free"
    var rating = 0
    var lastConfirmed = NSDate(timeIntervalSinceReferenceDate: 0)
    var approved = false
    
    override func viewDidLoad() {
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        delegate!.finishedWith("Cancel")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitButton(sender: AnyObject) {
        let newPost = PFObject(className: "Posts")

        newPost["Title"] = titleField.text!
        newPost["Description"] = descriptionField.text
        newPost["FoodType"] = foodType
        newPost["Price"] = price.text!
        newPost["Latitude"] = newPostLat!
        newPost["Longitude"] = newPostLon!
        newPost["Rating"] = rating
        newPost["LastConfirmed"] = lastConfirmed
        newPost["Approved"] = approved
        
        newPost.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {                
                //dismiss view controller and return to map
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    self.delegate!.finishedWith("Submit")
                })
            } else {
                //failure, notify of error
                let alert = UIAlertController(title: "Error Submitting Post", message: "Could not download posts from server. Please check your internet connection and try again.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func freeOrCheap(sender: AnyObject) {
        if freeOrCheapValue.selectedSegmentIndex == 0 {
            foodType = "free"
        } else if freeOrCheapValue.selectedSegmentIndex == 1 {
            foodType = "cheap"
        }
        //TODO: make the price cell appear if food is cheap
    }
}