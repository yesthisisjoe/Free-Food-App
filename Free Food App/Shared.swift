//
//  Shared.swift
//  Free Food App
//
//  Created by Joe Peplowski on 2015-05-05.
//  Copyright (c) 2015 Joseph Peplowski. All rights reserved.
//

import Foundation

struct Post {
    var id, title, description, type, price: String
    var posted, confirmed: NSDate
    var latitude, longitude: Double
    var status: Int
    var votes: [Vote]
    
    //initializer for when we download from the server
    init(id: String, title: String, description: String, type: String, posted: NSDate, confirmed: NSDate, latitude: Double, longitude: Double, status: Int, price: String) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.posted = posted
        self.confirmed = confirmed
        self.latitude = latitude
        self.longitude = longitude
        self.status = status
        self.price = price
        self.votes = []
    }
}

struct Vote {
    var id, postId: String
    var confirm: Bool
    var posted: NSDate
    
    init(id: String, postId: String, confirm: Bool, posted: NSDate) {
        self.id = id
        self.postId = postId
        self.confirm = confirm
        self.posted = posted
    }
}

public func dateSimplifier(sinceDate: NSDate) -> String {
    let elapsedTime = Int(NSDate().timeIntervalSinceDate(sinceDate))
    var simplifiedDate = ""
    
    if (elapsedTime < 60) { //less than a minute
        simplifiedDate = "less than 1m ago"
    } else if (elapsedTime >= 60 && elapsedTime < 60*60) { //less than an hour
        simplifiedDate = "\(elapsedTime / 60)m ago"
    } else if (elapsedTime >= 60*60 && elapsedTime < 60*60*24) { //less than a day
        simplifiedDate = "\(elapsedTime / 60 / 60)h ago"
    } else { //over a day
        simplifiedDate = "\(elapsedTime / 60 / 60 / 24)d ago"
    }
    
    return simplifiedDate
}