//
//  NearbyPostNotificationSettingsTableViewController.swift
//  Free Food App
//
//  Created by Joe Peplowski on 2015-06-15.
//  Copyright © 2015 Joseph Peplowski. All rights reserved.
//

import UIKit

class NearbyPostNotificationSettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var freeFoodSwitch: UISwitch!
    @IBOutlet weak var cheapFoodSwitch: UISwitch!
    @IBOutlet weak var cheapFoodLabel: UILabel!
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        //disable cheap food cell if cheap food is disabled
        if (defaults.objectForKey("onlyFree")! as! NSObject == true) {
            cheapFoodLabel.enabled = false
            cheapFoodSwitch.enabled = false
        }
        
        //set default switch state
        freeFoodSwitch.setOn(defaults.objectForKey("freeNearbyNotifications") as! Bool, animated: false)
        cheapFoodSwitch.setOn(defaults.objectForKey("cheapNearbyNotifications") as! Bool, animated: false)
    }
    
    //free food switch
    @IBAction func freeFoodSwitchAction(sender: AnyObject) {
        let switchOn = freeFoodSwitch.on
        defaults.setObject(switchOn, forKey: "freeNearbyNotifications")
    }
    
    //cheap food switch
    @IBAction func cheapFoodSwitchAction(sender: AnyObject) {
        let switchOn = cheapFoodSwitch.on
        defaults.setObject(switchOn, forKey: "cheapNearbyNotifications")
    }
}
