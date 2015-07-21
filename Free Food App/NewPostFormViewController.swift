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
    
    override func viewDidLoad() {
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        delegate!.finishedWith("Cancel")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitButton(sender: AnyObject) {
        print(titleField.text!)
        print(descriptionField.text)
        print(foodType)
        print(price.text!)
        print(newPostLat!)
        print(newPostLon!)
        print(rating)
        
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.delegate!.finishedWith("Submit")
        })
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