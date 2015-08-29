//
//  PostViewController.swift
//  Free Food App
//
//  Created by Joe Peplowski on 2015-08-29.
//  Copyright © 2015 Joseph Peplowski. All rights reserved.
//

import UIKit

class PostViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var postTableView: UITableView!
    
    let dataSourceArray = ["uno", "dos", "tres"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourceArray.count // Most of the time my data source is an array of something...  will replace with the actual name of the data source
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")
        
        cell!.textLabel!.text = dataSourceArray[indexPath.row]
        return cell!
    }
}