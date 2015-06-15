//
//  SettingsViewController.swift
//  Free Food App
//
//  Created by Joe Peplowski on 2015-05-15.
//  Copyright (c) 2015 Joseph Peplowski. All rights reserved.
//

import UIKit


class SettingsViewController: UITableViewController {
    @IBOutlet weak var onlyFreeSwitch: UISwitch!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var onlyFreeCell: UITableViewCell!
    @IBOutlet weak var sortCell: UITableViewCell!
    
    var onlyFree = true
    var sortBy = "rating"
    
    override func viewDidLoad() {
        //make sure the first 2 cells don't get highlighted when they are tapped
        onlyFreeCell.selectionStyle = UITableViewCellSelectionStyle.None
        sortCell.selectionStyle = UITableViewCellSelectionStyle.None
        
        //set the value of buttons to reflect existing values
        onlyFreeSwitch.setOn(onlyFree, animated: false)
        if (sortBy == "confirmed") {
            segmentedControl.selectedSegmentIndex = 0
        } else if (sortBy == "posted") {
            segmentedControl.selectedSegmentIndex = 1
        } else if (sortBy == "rating") {
            segmentedControl.selectedSegmentIndex = 2
        }
        
        super.viewDidLoad()
    }
    
    //segues to the proper table view when the user taps new post or nearby post
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 1 && indexPath.row == 0) {
            self.performSegueWithIdentifier("NewPost", sender: self)
        } else if (indexPath.section == 1 && indexPath.row == 1) {
            self.performSegueWithIdentifier("NearbyPost", sender: self)
        }
    }
    
    //gets data from segmented control
    @IBAction func valueChanged(sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex {
            case 0:
                sortBy = "confirmed"
            case 1:
                sortBy = "posted"
            case 2:
                sortBy = "rating"
            default:
                break
        }
    }
    
    //this is the only free food switch
    @IBAction func onlyFree(sender: AnyObject) {
        onlyFree = onlyFreeSwitch.on
    }
    
    @IBAction func doneButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
