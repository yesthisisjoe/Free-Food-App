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
    @IBOutlet weak var cheapFoodLabel: UILabel!
    
    let user = User.sharedInstance //necessary to access data in Shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        //disable the cheap food cell if cheap food is disabled
        if (user.onlyFree == true) {
            cheapFoodLabel.enabled = false
            cheapFoodSwitch.enabled = false
        }
        //set default switch state
        freeFoodSwitch.setOn(user.freePostNotifications, animated: false)
        cheapFoodSwitch.setOn(user.cheapPostNotifications, animated: false)
    }
    
    @IBAction func freeFoodSwitchAction(sender: AnyObject) {
        user.freePostNotifications = freeFoodSwitch.on
    }
    
    @IBAction func cheapFoodSwitchAction(sender: AnyObject) {
        user.cheapPostNotifications = cheapFoodSwitch.on
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}