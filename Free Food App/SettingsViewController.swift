//
//  SettingsViewController.swift
//  Free Food App
//
//  Created by Joe Peplowski on 2015-05-15.
//  Copyright (c) 2015 Joseph Peplowski. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    @IBOutlet weak var onlyFree: UISwitch!
    
    override func viewDidLoad() {
        //stuff
        
        super.viewDidLoad()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 1 && indexPath.row == 0) {
            self.performSegueWithIdentifier("NewPost", sender: self)
        } else if (indexPath.section == 1 && indexPath.row == 1) {
            self.performSegueWithIdentifier("NearbyPost", sender: self)
        }
    }
    
    @IBAction func onlyFree(sender: AnyObject) {
        //this is the only free food switch
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
