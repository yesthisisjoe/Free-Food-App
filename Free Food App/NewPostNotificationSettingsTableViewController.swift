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
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        //disable the cheap food cell if cheap food is disabled
        if (NSUserDefaults.standardUserDefaults().objectForKey("onlyFree") as! Bool == true) {
            cheapFoodLabel.enabled = false
            cheapFoodSwitch.enabled = false
        }
        //set default switch state
        freeFoodSwitch.setOn(NSUserDefaults.standardUserDefaults().objectForKey("freePostNotifications") as! Bool, animated: false)
        cheapFoodSwitch.setOn(NSUserDefaults.standardUserDefaults().objectForKey("cheapPostNotifications") as! Bool, animated: false)
    }
    
    @IBAction func freeFoodSwitchAction(sender: AnyObject) {
        let switchOn = freeFoodSwitch.on
        NSUserDefaults.standardUserDefaults().setObject(switchOn, forKey: "freePostNotifications")
    }
    
    @IBAction func cheapFoodSwitchAction(sender: AnyObject) {
        let switchOn = cheapFoodSwitch.on
        NSUserDefaults.standardUserDefaults().setObject(switchOn, forKey: "cheapPostNotifications")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}