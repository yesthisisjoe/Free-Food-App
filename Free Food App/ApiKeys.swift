//
//  ApiKeys.swift
//  Free Food App
//
//  Created by Joe Peplowski on 2015-08-18.
//  Copyright © 2015 Joseph Peplowski. All rights reserved.
//

import Foundation

func valueForAPIKey(keyname:String) -> String {
    let filePath = NSBundle.mainBundle().pathForResource("ApiKeys", ofType:"plist")
    let plist = NSDictionary(contentsOfFile:filePath!)
    
    let value:String = plist?.objectForKey(keyname) as! String
    return value
}