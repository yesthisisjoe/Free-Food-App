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
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        /*print("Did change authorization status: ")
        
        switch status {
        case .NotDetermined:
            print("not determined")
            break
            
        case .AuthorizedWhenInUse:
            print("authorized when in use")
            self.locationManager.startUpdatingLocation()
            break
            
        case .AuthorizedAlways:
            print("authorized always")
            self.locationManager.startUpdatingLocation()
            break
            
        case .Denied:
            print("denied")
            break
            
        default:
            print("unhandled authorization status")
            break
        }*/
    }
}

let SharedUserLocation = CoreLocationController()