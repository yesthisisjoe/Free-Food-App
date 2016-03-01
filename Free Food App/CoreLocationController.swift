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
            break
            
        case .AuthorizedWhenInUse:
            NSLog("authorized when in use")
            self.locationManager.startUpdatingLocation()
            break
            
        case .AuthorizedAlways:
            NSLog("authorized always")
            self.locationManager.startUpdatingLocation()
            break
            
        case .Denied:
            NSLog("denied")
            break
            
        default:
            NSLog("unhandled authorization status")
            break
        }*/
    }
}

let SharedUserLocation = CoreLocationController()