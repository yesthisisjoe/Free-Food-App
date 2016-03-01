//
//  NewPostNotificationSettingsTableViewController.swift
//  Free Food App
//
//  Created by Joe Peplowski on 2015-06-15.
//  Copyright © 2015 Joseph Peplowski. All rights reserved.
//

import UIKit
import Parse

class NewPostNotificationSettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var freeFoodSwitch: UISwitch!
    @IBOutlet weak var cheapFoodSwitch: UISwitch!
    @IBOutlet weak var cheapFoodLabel: UILabel!
    
    let defaults = NSUserDefaults.standardUserDefaults()
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        //disable the cheap food cell if cheap food is disabled
        if (defaults.objectForKey("onlyFree") as! Bool == true) {
            cheapFoodLabel.enabled = false
            cheapFoodSwitch.enabled = false
        }
        
        //set default switch state
        freeFoodSwitch.setOn(defaults.objectForKey("freePostNotifications") as! Bool, animated: false)
        cheapFoodSwitch.setOn(defaults.objectForKey("cheapPostNotifications") as! Bool, animated: false)
    }
    
    //free food switch
    @IBAction func freeFoodSwitchAction(sender: AnyObject) {
        let switchOn = freeFoodSwitch.on
        let currentInstallation = PFInstallation.currentInstallation()
        
        if (switchOn) {
            //subscribe to the new free post notifications parse channel
            currentInstallation.addUniqueObject("FreePostNotifications", forKey: "channels")
        } else {
            //unsubscribe if we switch this setting off
            currentInstallation.removeObject("FreePostNotifications", forKey: "channels")
        }
        
        //save this setting to the phone and Parse
        currentInstallation.saveEventually()
        defaults.setObject(switchOn, forKey: "freePostNotifications")
    }
    
    //cheap food switch
    @IBAction func cheapFoodSwitchAction(sender: AnyObject) {
        let switchOn = cheapFoodSwitch.on
        let currentInstallation = PFInstallation.currentInstallation()
        
        if (switchOn) {
            //subscribe to the new free post notifications parse channel
            currentInstallation.addUniqueObject("CheapPostNotifications", forKey: "channels")
        } else {
            //unsubscribe if we switch this setting off
            currentInstallation.removeObject("CheapPostNotifications", forKey: "channels")
        }
        
        //save this setting to the phone and Parse
        currentInstallation.saveEventually()
        defaults.setObject(switchOn, forKey: "cheapPostNotifications")
    }
}