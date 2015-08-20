//
//  SettingsViewController.swift
//  Free Food App
//
//  Created by Joe Peplowski on 2015-05-15.
//  Copyright (c) 2015 Joseph Peplowski. All rights reserved.
//

import UIKit
import MessageUI
import Parse

class SettingsViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var onlyFreeSwitch: UISwitch!
    @IBOutlet weak var onlyFreeCell: UITableViewCell!
    @IBOutlet weak var newPostNotificationText: UILabel!
    @IBOutlet weak var nearbyPostNotificationText: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    var settingsChanged: Bool? //do we need to refresh pins/list when we exit settings?
    var initialOnlyFree: Bool? //what is the initial only free option?
    var delegate: SettingsViewDelegate?
    let subscribedChannels = PFInstallation.currentInstallation().channels //checks what channels the user is subscribed to (for notifications)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //tableView.delegate = self
        
        //make sure the first 2 cells don't get highlighted when they are tapped
        onlyFreeCell.selectionStyle = UITableViewCellSelectionStyle.None
        
        //set the value of buttons to reflect existing values
        onlyFreeSwitch.setOn(NSUserDefaults.standardUserDefaults().objectForKey("onlyFree") as! Bool, animated: false)
        
        //set the version number in the settings
        if let versionObject = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = versionObject
        }
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
        
            //triggers the mail compose view controller for feedback
        else if (indexPath.section == 2 && indexPath.row == 1) {
            let mailComposeViewController = configuredMailComposeViewController("Feedback for the Free Food app")
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
            
        } else if (indexPath.section == 2 && indexPath.row == 2) {
            print("app store review link")
            
            //email form for moderation
        } else if (indexPath.section == 2 && indexPath.row == 3) {
            let mailComposeViewController = configuredMailComposeViewController("Becoming a Free Food app Moderator")
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    //configure the mail composer for when we want to send feedback
    func configuredMailComposeViewController(subject: String) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["joseph.peplowski@mail.mcgill.ca"])
        mailComposerVC.setSubject(subject)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let alert = UIAlertController(title: "Could Not Send Email", message:"Your email message could not be sent. Please check your email settings and try again.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
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
                    //turn off the notifications and turn on only free in core data
                    NSUserDefaults.standardUserDefaults().setObject(true, forKey: "onlyFree")
                    NSUserDefaults.standardUserDefaults().setObject(false, forKey: "cheapPostNotifications")
                    NSUserDefaults.standardUserDefaults().setObject(false, forKey: "cheapNearbyNotifications")
                    
                    //remove the user from the notification channels in Parse
                    let currentInstallation = PFInstallation.currentInstallation()
                    currentInstallation.removeObject("FreePostNotifications", forKey: "channels")
                    currentInstallation.removeObject("CheapPostNotifications", forKey: "channels")
                    currentInstallation.saveEventually()
                    
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
