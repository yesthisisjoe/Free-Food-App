//
//  NewPostFormViewController.swift
//  Free Food App
//
//  Created by Joe Peplowski on 2015-07-05.
//  Copyright © 2015 Joseph Peplowski. All rights reserved.
//

//TODO:
//      -generally fix up the new post form

import UIKit
import Parse

protocol NewPostFormViewControllerDelegate {
    func finishedWith(button: String)
}

class NewPostFormViewController: UITableViewController, UITextViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var freeOrCheapValue: UISegmentedControl!
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionPlaceholder: UITextView!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var priceCell: UITableViewCell!
    
    var delegate: NewPostFormViewControllerDelegate! = nil
    var newPostLat: Double?
    var newPostLon: Double?
    var foodType = "free"
    var rating = 0
    var lastConfirmed = NSDate(timeIntervalSinceReferenceDate: 0)
    var approved = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set all the delegates we need to know when text changes in each field
        price.delegate = self
        titleField.delegate = self
        descriptionField.delegate = self
        
        tableView.delegate = self
        tableView.tableFooterView = UIView() //hides extra lines at table footer
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.row {
            //shows or hides the price cell based on whether the post is free or cheap
        case 1:
            if priceCell.hidden == true {
                return 0
            } else {
                return 44
            }
        case 3:
            return 198
        default:
            return 44
        }
    }
    
    //hide the placeholder text when we start typing in the description
    func textViewDidChange(textView: UITextView) {
        if descriptionField.text.isEmpty == false {
            descriptionPlaceholder.text = ""
        } else {
            descriptionPlaceholder.text = "Description"
        }
        
        //max length of the description field
        if descriptionField.text!.characters.count > 300 {
            descriptionField.deleteBackward()
        }
    }
    @IBAction func priceFieldChanged(sender: AnyObject) {
        checkTextFieldLength(price, maxLength: 20)
    }
    
    @IBAction func titleFieldChanged(sender: AnyObject) {
        checkTextFieldLength(titleField, maxLength: 40)
    }
    
    func checkTextFieldLength(textField: UITextField!, maxLength: Int) {
        if textField.text!.characters.count > maxLength {
            textField.deleteBackward()
        }
    }
    
    //when we hit return in the first 2 fields we select the next one
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == price) {
            titleField.becomeFirstResponder()
        } else if (textField == titleField) {
            descriptionField.becomeFirstResponder()
        }
        return true
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
            (success, error) -> Void in
            if (success) {                
                //dismiss view controller and return to map
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    self.delegate!.finishedWith("Submit")
                })
            } else {
                //failure, notify of error
                let alert = UIAlertController(title: "Error Submitting Post", message: "Could not submit post. Please check your internet connection and try again.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func freeOrCheap(sender: AnyObject) {
        if freeOrCheapValue.selectedSegmentIndex == 0 {
            foodType = "free"
            priceCell.hidden = true
        } else if freeOrCheapValue.selectedSegmentIndex == 1 {
            foodType = "cheap"
            priceCell.hidden = false
        }
        tableView.reloadData()
    }
}