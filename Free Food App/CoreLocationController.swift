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
        
    }
}