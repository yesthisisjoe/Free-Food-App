//
//  Shared.swift
//  Free Food App
//
//  Created by Joe Peplowski on 2015-05-05.
//  Copyright (c) 2015 Joseph Peplowski. All rights reserved.
//

import Foundation

struct Post {
    var id, title, description, type: String
    var created, confirmed: NSDate
    var latitude, longitude: Double
    var rating: Int
    
    //initializer for when we download from the server
    init(id: String, title: String, description: String, type: String, created: NSDate, confirmed: NSDate, latitude: Double, longitude: Double, rating: Int) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.created = created
        self.confirmed = confirmed
        self.latitude = latitude
        self.longitude = longitude
        self.rating = rating
    }
    
    //initializer for when we create a new post
    /*init(title: String, description: String, type: String, latitude: Double, longitude: Double) {
        self.title = title
        self.description = description
        self.type = type
        self.latitude = latitude
        self.longitude = longitude
        id = ""
        confirmed = NSDate()
        created = NSDate()
        rating = 0
    }*/
}