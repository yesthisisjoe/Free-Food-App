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
    @IBOutlet weak var newPostNotificationText: UILabel!
    @IBOutlet weak var nearbyPostNotificationText: UILabel!
    
    let user = User.sharedInstance //necessary to access data in Shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //make sure the first 2 cells don't get highlighted when they are tapped
        onlyFreeCell.selectionStyle = UITableViewCellSelectionStyle.None
        sortCell.selectionStyle = UITableViewCellSelectionStyle.None
        
        //set the value of buttons to reflect existing values
        onlyFreeSwitch.setOn(user.onlyFree, animated: false)
        if (user.sortBy == "confirmed") {
            segmentedControl.selectedSegmentIndex = 0
        } else if (user.sortBy == "posted") {
            segmentedControl.selectedSegmentIndex = 1
        } else if (user.sortBy == "rating") {
            segmentedControl.selectedSegmentIndex = 2
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        updateRightDetail()
    }
    
    //set the right detail of the notifications settings to their state
    func updateRightDetail() {
        if (user.freePostNotifications == true) {
            if (user.cheapPostNotifications == true) {
                newPostNotificationText.text = "Free & Cheap"
            } else {
                newPostNotificationText.text = "Free"
            }
        } else {
            if (user.cheapPostNotifications == true) {
                newPostNotificationText.text = "Cheap"
            } else {
                newPostNotificationText.text = "Off"
            }
        }
        
        if (user.freeNearbyNotifications == true) {
            if (user.cheapNearbyNotifications == true) {
                nearbyPostNotificationText.text = "Free & Cheap"
            } else {
                nearbyPostNotificationText.text = "Free"
            }
        } else {
            if (user.cheapNearbyNotifications == true) {
                nearbyPostNotificationText.text = "Cheap"
            } else {
                nearbyPostNotificationText.text = "Off"
            }
        }
    }
    
    //segues to the proper table view when the user taps new post or nearby post
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 1 && indexPath.row == 0) {
            self.performSegueWithIdentifier("NewPost", sender: self)
        } else if (indexPath.section == 1 && indexPath.row == 1) {
            self.performSegueWithIdentifier("NearbyPost", sender: self)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //gets data from segmented control
    @IBAction func valueChanged(sender: AnyObject) {
        switch segmentedControl.selectedSegmentIndex {
            case 0:
                user.sortBy = "confirmed"
            case 1:
                user.sortBy = "posted"
            case 2:
                user.sortBy = "rating"
            default:
                break
        }
    }
    
    //this is the only free food switch
    @IBAction func onlyFree(sender: AnyObject) {
        
        //user wants to only see free food
        if (onlyFreeSwitch.on == true) {
            
            //user has cheap food notifications on
            if (user.cheapPostNotifications || user.cheapNearbyNotifications) {
                
                //confirm with the user that this will turn off their cheap food notifications
                let alert = UIAlertController(title: "Turn Off Cheap Food Notifications?", message: "Only showing free food will turn off cheap food notifications. You will have to manually turn these back on if you change your mind later.", preferredStyle: UIAlertControllerStyle.Alert)
                
                //the user is OK with this, so turn off cheap food and cheap food notifications
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    self.user.onlyFree = true
                    self.user.cheapPostNotifications = false
                    self.user.cheapNearbyNotifications = false
                    self.updateRightDetail()
                }))
                
                //the user cancelled, so reset the switch and change no settings
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
                    (alert: UIAlertAction!) -> Void in
                    self.onlyFreeSwitch.setOn(false, animated: true)
                }))
                
                self.presentViewController(alert, animated: true, completion: nil)
                
            //user doesn't have any cheap food notifications. we turn on only free food
            } else {
                user.onlyFree = true
            }
            
        //user is turning off only free food
        } else {
            user.onlyFree = false
        }
    }
    
    @IBAction func doneButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
