//
//  NewPostFormViewController.swift
//  Free Food App
//
//  Created by Joe Peplowski on 2015-07-05.
//  Copyright © 2015 Joseph Peplowski. All rights reserved.
//

//TODO: -format dollar sign in price

import UIKit



class NewPostFormViewController: UITableViewController {

    @IBOutlet weak var freeOrCheapValue: UISegmentedControl!
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionPlaceholder: UITextView!
    @IBOutlet weak var descriptionField: UITextView!
    
    @IBAction func cancelButton(sender: AnyObject) {
        print("cancel")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func submitButton(sender: AnyObject) {
        print("submit")
    }
    
    @IBAction func freeOrCheap(sender: AnyObject) {
        //make the price cell appear if food is cheap
    }
    
    
}