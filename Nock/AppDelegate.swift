//
//  AppDelegate.swift
//  Nock
//
//  Created by Albin Martinsson on 2015-10-02.
//  Copyright © 2015 Johan Martinsson. All rights reserved.
//

import UIKit
import CoreLocation
import FBSDKCoreKit
import RealmSwift
import Alamofire
import SwiftyJSON
import Parse

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    var window: UIWindow?
    let defaults = NSUserDefaults.standardUserDefaults()
    var locationManager = CLLocationManager()
    var beaconRegion = CLBeaconRegion()
    var lastFoundBeacon: CLBeacon! = CLBeacon()
    var lastProximity: CLProximity! = CLProximity.Unknown
    //Proximity id, we should fetch this from db later on
    //var proximityUUID = NSUUID(UUIDString: "A4951234-C5B1-4B44-B512-1370F02D74DE")!
    var proximityUUID = NSUUID(UUIDString: "E20A39F4-73F5-4BC4-A12F-17D1AD07A969")!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        setBarTintColor()
        //Ask for permission to user the users location
        locationManager.requestAlwaysAuthorization()
        
        Parse.setApplicationId("Kz4LL3tKVzKUPkSdOn992yKY7OLjQltQB5H74NFG", clientKey: "3iO8dPwLYC5tQ5tZcEtbM31M1f8ht69TyhipDvYx")
        
        //Check if user is signed in
        let realm = try! Realm()
        let user = realm.objects(User)
        if user.isEmpty {
            //User is not logged in
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewControllerWithIdentifier("AuthViewController") as! AuthViewController
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()
        } else {
            //User is logged in
            self.window = UIWindow(frame: UIScreen.mainScreen().bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initialViewController = storyboard.instantiateViewControllerWithIdentifier("CustomTabBarController") as! CustomTabBarController
            self.window?.rootViewController = initialViewController
            self.window?.makeKeyAndVisible()

            //Start to look for beacons
            self.lookForBeacons()
        }
        
        //Ask user for push permission
        if application.respondsToSelector("registerUserNotificationSettings:") {
            let userNotificationTypes: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
            let settings = UIUserNotificationSettings(forTypes: userNotificationTypes, categories: nil)
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
        } else {
            application.registerForRemoteNotificationTypes([.Badge, .Sound, .Alert])
        }
        
        return FBSDKApplicationDelegate.sharedInstance()
            .application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        //Convert deviceToken (NSData) to String
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for var i = 0; i < deviceToken.length; i++ {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        //Save devicetoken to userDefaults
        defaults.setObject(tokenString, forKey: "userDeviceToken")
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print(userInfo)
        PFPush.handlePush(userInfo)
        if application.applicationState == UIApplicationState.Inactive {
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
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
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url,sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func setBarTintColor() {
        //Change NavigationBar tint color to clearcolor
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor()]
        UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarMetrics: .Default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().backgroundColor = UIColor.clearColor()
        UINavigationBar.appearance().translucent = true
    }
    
    func lookForBeacons() {
        print("Start beacon")
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.delegate = self
        beaconRegion = CLBeaconRegion(proximityUUID: proximityUUID, major: 4386, minor: 13124, identifier: "beaconRegion")
        locationManager.startMonitoringForRegion(beaconRegion)
        //locationManager.startRangingBeaconsInRegion(beaconRegion)
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
        beaconRegion.notifyEntryStateOnDisplay = true
        locationManager.startUpdatingLocation()
    }

    //MARK: LocationManager BeaconRegion
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        if let foundBeacons = beacons as? [CLBeacon] {
            if foundBeacons.count > 0 {
                if let closestBeacon = foundBeacons[0] as? CLBeacon {
                    if closestBeacon != lastFoundBeacon || lastProximity != closestBeacon.proximity  {
                        var proximityMessage: String!
                        lastFoundBeacon = closestBeacon
                        lastProximity = closestBeacon.proximity
                        
                        switch lastFoundBeacon.proximity {
                        case CLProximity.Immediate:
                            proximityMessage = "Very close"
                            
                        case CLProximity.Near:
                            proximityMessage = "Near"
                            
                        case CLProximity.Far:
                            proximityMessage = "Far"
                        default:
                            proximityMessage = "Did range beacon, proximity unknown"
                        }
                        print(proximityMessage)
                    }
                }
            }
        }
    }
    
    //MARK: LocationManager Region
    func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
        locationManager.requestStateForRegion(beaconRegion)
    }
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        locationManager.startRangingBeaconsInRegion(beaconRegion)
        print(state)
    }
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        //Here we should checkIN the user
        print("Entered region!")
        var localn = UILocalNotification()
        localn.alertBody = "Entered region"
        localn.soundName = UILocalNotificationDefaultSoundName;
        UIApplication.sharedApplication().presentLocalNotificationNow(localn)
        self.checkIn()
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        //Here we should checkout the user
        print("Exited region!")
        var localn = UILocalNotification()
        localn.alertBody = "Exited region"
        localn.soundName = UILocalNotificationDefaultSoundName
        UIApplication.sharedApplication().presentLocalNotificationNow(localn)
        self.checkOut()
    }
    
    // MARK: Check in & Check out
    func checkIn() {
        let realm = try! Realm()
        let user = realm.objects(User)[0]
        print(user)
        let headers = ["X-Authentication-Token": user.token]
        let parameters = ["status": 1]
        Alamofire.request(.PUT, "http://52.31.123.168//api/v1/users/\(user.id)/status", headers: headers, parameters: parameters)
            .responseData { (request, response, data) in
                if response?.statusCode == 200 {
                    let json = JSON(data: data.value!)
                    print(json)
                } else {
                    print("Error fetching data")
                    print(response)
                }
        }
    }
    
    func checkOut() {
        let realm = try! Realm()
        let user = realm.objects(User)[0]
        print(user)
        let headers = ["X-Authentication-Token": user.token]
        let parameters = ["status": 0]
        Alamofire.request(.PUT, "http://52.31.123.168//api/v1/users/\(user.id)/status", headers: headers, parameters: parameters)
            .responseData { (request, response, data) in
                if response?.statusCode == 200 {
                    let json = JSON(data: data.value!)
                    print(json)
                } else {
                    print("Error fetching data")
                    print(response)
                }
        }
    }
}