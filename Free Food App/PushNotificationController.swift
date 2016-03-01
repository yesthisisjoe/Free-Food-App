//
//  PushNotificationController.swift
//  Free Food App
//
//  Created by Joe Peplowski on 2015-08-18.
//  Copyright © 2015 Joseph Peplowski. All rights reserved.
//

import Foundation
import Parse

//setup for Parse push notifcations
class PushNotificationController : NSObject {
    override init() {
        super.init()
        
        let parseApplicationID = valueForAPIKey("PARSE_APPLICATION_ID")
        let parseClientKey = valueForAPIKey("PARSE_CLIENT_KEY")
        
        Parse.setApplicationId(parseApplicationID, clientKey: parseClientKey)
    }
}