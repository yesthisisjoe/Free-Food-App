//
//  AppDelegate.swift
//  Free Food App
//
//  Created by Joe Peplowski on 2015-05-04.
//  Copyright (c) 2015 Joseph Peplowski. All rights reserved.
//

import UIKit
import Parse
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var pushNotificationController: PushNotificationController?
    var coreLocationController: CoreLocationController?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //initialize Parse
        Parse.setApplicationId(valueForAPIKey("PARSE_APPLICATION_ID"),
            clientKey: valueForAPIKey("PARSE_CLIENT_KEY"))
        PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        //set default preferences
        guard let defaultPrefsFile = NSBundle.mainBundle().pathForResource("DefaultSettings", ofType: "plist")
            else { NSLog("Error loading default preferences file."); return true }
        let defaultPreferences = NSDictionary(contentsOfFile: defaultPrefsFile)
        guard let defaultPreferencesString = defaultPreferences as? [String: AnyObject]
            else { NSLog("Error converting default preferences to string dictionary."); return true }
        NSUserDefaults.standardUserDefaults().registerDefaults(defaultPreferencesString)
        
        self.pushNotificationController = PushNotificationController()
        self.coreLocationController = CoreLocationController()
        
        //set up for push notifications
        if application.respondsToSelector(#selector(UIApplication.registerUserNotificationSettings(_:))) {
            //for iOS 8
            let notificationType: UIUserNotificationType = [.Alert, .Sound, .Badge]
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: notificationType, categories: nil)
            
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            //for pre-iOS 8
            application.registerForRemoteNotificationTypes([.Alert, .Badge, .Sound])
        }
        
        //set appearance of navigation bar title in settings
        guard let navBarFont = UIFont(name: "AvenirNext-Bold", size: 18)
            else { NSLog("Error setting navigation bar font."); return true }
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: navBarFont]
        
        //same for the buttons in settings
        guard let buttonFont = UIFont(name: "AvenirNext-Bold", size: 18)
            else { NSLog("Error setting button font."); return true }
        UIBarButtonItem.appearance().setTitleTextAttributes([NSFontAttributeName: buttonFont, NSForegroundColorAttributeName: UIColor(red: 65/255, green: 122/255, blue: 198/255, alpha: 1)], forState: UIControlState.Normal)
        
        return true
    }
    
    //notifications setup
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let currentInstallation:PFInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.save()
        
        NSLog("successfully registered for push notifications")
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        NSLog(error.localizedDescription)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        let notification:NSDictionary = userInfo["aps"] as! NSDictionary
        if (notification["content-available"] != nil){
            if notification.objectForKey("content-available")!.isEqualToNumber(1){
                NSNotificationCenter.defaultCenter().postNotificationName("reloadTimeline", object: nil)
            }
        }else{
            PFPush.handlePush(userInfo)
        }
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }
}

