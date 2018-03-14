//
//  CustomScenicViewModel.swift
//  ScenicMap
//
//  Created by Yi Jiang on 14/3/18.
//  Copyright © 2018 Siphty. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Firebase
import CoreLocation
import ObjectMapper

class CustomScenicViewModel {
    
    let disposeBag = DisposeBag()
    var locationManager: CLLocationManager? = nil
    var locations = Variable<[Location]>([])
    
    func fetchCustomScenic() {
        let rootRef = Database.database().reference()
        rootRef.child("scenics")
            .queryOrderedByKey()
            .observeSingleEvent(of: .value,
                                with: { scenics in
                                    guard let jsonDict = scenics.value as? NSDictionary else {
                                        return
                                    }
                                    print(jsonDict.description)
                                    let scenicsDict = jsonDict.map{ (arg) -> [String: Any] in
                                        let (_, value) = arg
                                        return value as! [String: Any]
                                        }
                                    let response = ["locations": scenicsDict, "updated": ""] as [String : Any]
                                    let slResponse = Mapper<SLResponse>().map(JSON: response)
                                    guard let lcoations = slResponse?.locations else { return }
                                    self.locations.value = lcoations
            })
    }
    
    func addCustomScenic(_ scenic: Location) {
        let scenicsRef = Database.database().reference(withPath: "scenics")
        scenicsRef.child("\(scenic.hashValue)").setValue(Mapper().toJSON(scenic))
    }
    
    fileprivate func bindLocations() {
        locations.asObservable()
            .subscribe(onNext: {locations in
            
        }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }
}

extension CustomScenicViewModel {
    
    fileprivate func getCurrentLocation() -> CLLocation? {
        guard let locationManager = locationManager else { return nil }
        var currentLocation: CLLocation? = nil
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined, .restricted, .denied:
                if #available(iOS 11.0, *) {
                    locationManager.requestAlwaysAuthorization()
                } else {
                    locationManager.requestWhenInUseAuthorization()
                }
            case .authorizedAlways, .authorizedWhenInUse:
                currentLocation = locationManager.location
            }
        } else {
            print("Location services are not enabled")
        }
        return currentLocation
    }
}

