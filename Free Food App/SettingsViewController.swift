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
    @IBOutlet weak var onlyFreeCell: UITableViewCell!
    @IBOutlet weak var newPostNotificationText: UILabel!
    @IBOutlet weak var nearbyPostNotificationText: UILabel!
    
    var settingsChanged: Bool? //do we need to refresh pins/list when we exit settings?
    var initialOnlyFree: Bool? //what is the initial only free option?
    var delegate: SettingsViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //make sure the first 2 cells don't get highlighted when they are tapped
        onlyFreeCell.selectionStyle = UITableViewCellSelectionStyle.None
        
        //set the value of buttons to reflect existing values
        onlyFreeSwitch.setOn(NSUserDefaults.standardUserDefaults().objectForKey("onlyFree") as! Bool, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        updateRightDetail()
    }
    
    //set the right detail of the notifications settings to their state
    func updateRightDetail() {
        if (NSUserDefaults.standardUserDefaults().objectForKey("freePostNotifications") as! Bool == true) {
            if (NSUserDefaults.standardUserDefaults().objectForKey("cheapPostNotifications") as! Bool == true) {
                newPostNotificationText.text = "Free & Cheap"
            } else {
                newPostNotificationText.text = "Free"
            }
        } else {
            if (NSUserDefaults.standardUserDefaults().objectForKey("cheapPostNotifications") as! Bool == true) {
                newPostNotificationText.text = "Cheap"
            } else {
                newPostNotificationText.text = "Off"
            }
        }
        
        if (NSUserDefaults.standardUserDefaults().objectForKey("freeNearbyNotifications") as! Bool == true) {
            if (NSUserDefaults.standardUserDefaults().objectForKey("cheapNearbyNotifications") as! Bool == true) {
                nearbyPostNotificationText.text = "Free & Cheap"
            } else {
                nearbyPostNotificationText.text = "Free"
            }
        } else {
            if (NSUserDefaults.standardUserDefaults().objectForKey("cheapNearbyNotifications") as! Bool == true) {
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
    
    //this is the only free food switch
    @IBAction func onlyFree(sender: AnyObject) {
        
        //user wants to only see free food
        if (onlyFreeSwitch.on == true) {
            
            //user has cheap food notifications on
            if (NSUserDefaults.standardUserDefaults().objectForKey("cheapPostNotifications") as! Bool || NSUserDefaults.standardUserDefaults().objectForKey("cheapNearbyNotifications") as! Bool) {
                
                //confirm with the user that this will turn off their cheap food notifications
                let alert = UIAlertController(title: "Turn Off Cheap Food Notifications?", message: "Only showing free food will turn off cheap food notifications. You will have to manually turn these back on if you change your mind later.", preferredStyle: UIAlertControllerStyle.Alert)
                
                //the user is OK with this, so turn off cheap food and cheap food notifications
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {
                    (alert: UIAlertAction!) -> Void in
                    NSUserDefaults.standardUserDefaults().setObject(true, forKey: "onlyFree")
                    NSUserDefaults.standardUserDefaults().setObject(false, forKey: "cheapPostNotifications")
                    NSUserDefaults.standardUserDefaults().setObject(false, forKey: "cheapNearbyNotifications")
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
                NSUserDefaults.standardUserDefaults().setObject(true, forKey: "onlyFree")
            }
            
        //user is turning off only free food
        } else {
            NSUserDefaults.standardUserDefaults().setObject(false, forKey: "onlyFree")
        }
    }
    
    @IBAction func doneButton(sender: AnyObject) {
        //if the only free setting changed we tell the view controller to reload posts
        if (initialOnlyFree != (NSUserDefaults.standardUserDefaults().objectForKey("onlyFree") as! Bool)) {
            settingsChanged = true
        }
        
        delegate?.editSettingsDidFinish(settingsChanged!)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

protocol SettingsViewDelegate{
    func editSettingsDidFinish(settingsChanged: Bool)
}
