//
//  NewPostNotificationSettingsTableViewController.swift
//  Free Food App
//
//  Created by Joe Peplowski on 2015-06-15.
//  Copyright © 2015 Joseph Peplowski. All rights reserved.
//

import UIKit

class NewPostNotificationSettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var freeFoodSwitch: UISwitch!
    @IBOutlet weak var cheapFoodSwitch: UISwitch!
    
    var freePostNotifications = true
    var cheapPostNotifications = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //set default switch state
        freeFoodSwitch.setOn(freePostNotifications, animated: false)
        cheapFoodSwitch.setOn(cheapPostNotifications, animated: false)
    }
    
    @IBAction func freeFoodSwitchAction(sender: AnyObject) {
        freePostNotifications = freeFoodSwitch.on
    }
    
    @IBAction func cheapFoodSwitchAction(sender: AnyObject) {
        cheapPostNotifications = cheapFoodSwitch.on
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}