//
//  Shared.swift
//  Free Food App
//
//  Created by Joe Peplowski on 2015-05-05.
//  Copyright (c) 2015 Joseph Peplowski. All rights reserved.
//

import Foundation

//this class holds data that needs to be shared between view controllers
class User {
    class var sharedInstance: User {
        struct Static {
            static var instance: User?
            static var token: dispatch_once_t = 0
        }
        
        dispatch_once(&Static.token) {
            Static.instance = User()
        }
        
        return Static.instance!
    }
    
    var posts = [Post]() //stores free food posts
    
    var onlyFree = false //toggles only showing free food
    var sortBy = "rating" //how the list view is sorted
    
    var freePostNotifications = false //toggles notifications for new free food posts
    var cheapPostNotifications = false //toggles notifications for new cheap food posts
    var freeNearbyNotifications = false //toggles notifications for nearby free food posts
    var cheapNearbyNotifications = false //toggles notifications for nearby cheap food posts
    
}

struct Post {
    var id, title, description, type: String
    var posted, confirmed: NSDate
    var latitude, longitude: Double
    var rating: Int
    
    //initializer for when we download from the server
    init(id: String, title: String, description: String, type: String, posted: NSDate, confirmed: NSDate, latitude: Double, longitude: Double, rating: Int) {
        self.id = id
        self.title = title
        self.description = description
        self.type = type
        self.posted = posted
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