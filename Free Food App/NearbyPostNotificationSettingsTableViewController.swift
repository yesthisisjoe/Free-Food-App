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

    var freeNearbyNotifications = false
    var cheapNearbyNotifications = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set default switch state
        freeFoodSwitch.setOn(freeNearbyNotifications, animated: false)
        cheapFoodSwitch.setOn(cheapNearbyNotifications, animated: false)
    }
    
    @IBAction func freeFoodSwitchAction(sender: AnyObject) {
        freeNearbyNotifications = freeFoodSwitch.on
    }
    
    @IBAction func cheapFoodSwitchAction(sender: AnyObject) {
        cheapNearbyNotifications = cheapFoodSwitch.on
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
