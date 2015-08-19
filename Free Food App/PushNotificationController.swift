//
//  PushNotificationController.swift
//  Free Food App
//
//  Created by Joe Peplowski on 2015-08-18.
//  Copyright © 2015 Joseph Peplowski. All rights reserved.
//
/* TODO:
 * -ask for notifications at the right time, not on startup
 */

import Foundation
import Parse

class PushNotificationController : NSObject {
    
    override init() {
        super.init()
        
        let parseApplicationID = valueForAPIKey("PARSE_APPLICATION_ID")
        let parseClientKey = valueForAPIKey("PARSE_CLIENT_KEY")
        
        Parse.setApplicationId(parseApplicationID, clientKey: parseClientKey)
    }
}