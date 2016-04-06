//
//  CoreLocationController.swift
//  Free Food App
//
//  Created by Joe Peplowski on 2015-08-19.
//  Copyright © 2015 Joseph Peplowski. All rights reserved.
//

import Foundation
import CoreLocation

class CoreLocationController: NSObject, CLLocationManagerDelegate {
    var locationManager: CLLocationManager = CLLocationManager()
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    class var manager: CoreLocationController {
        return SharedUserLocation
    }
    
    //location manager handler functions
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        /*NSLog("Did change authorization status: ")
        
        switch status {
        case .NotDetermined:
            NSLog("not determined")
         
        case .AuthorizedWhenInUse:
            NSLog("authorized when in use")
            self.locationManager.startUpdatingLocation()
         
        case .AuthorizedAlways:
            NSLog("authorized always")
            self.locationManager.startUpdatingLocation()
         
        case .Denied:
            NSLog("denied")
         
        default:
            NSLog("unhandled authorization status")
        }*/
    }
}

let SharedUserLocation = CoreLocationController()