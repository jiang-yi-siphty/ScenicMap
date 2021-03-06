//
//  AppDelegate.swift
//  ScenicMap
//
//  Created by Yi JIANG on 12/3/18.
//  Copyright © 2018 Siphty. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import Firebase
import FirebaseCore

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var locationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //MARK: Firebase
        FirebaseApp.configure()
        
        //MARK: LocationManager
        locationManager.delegate = self
        locationManager.desiredAccuracy = 10
        locationManager.distanceFilter = 20
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                if #available(iOS 11.0, *) {
                    locationManager.requestAlwaysAuthorization()
                } else {
                    locationManager.requestWhenInUseAuthorization()
                }
            default :
                break
                //Do nothing.
            }
        }
        locationManager.startUpdatingLocation()
        return true
    }
    
}

//MARK: - CLLocationManagerDelegate
extension AppDelegate: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let locationDict:[String: CLLocation] = ["location": (locations.last)!]
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:Notification.didUpdateLocations),
                                        object: nil,
                                        userInfo: locationDict)
    }
    
}

