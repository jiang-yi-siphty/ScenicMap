//
//  ScenicLocationViewModel.swift
//  ScenicMap
//
//  Created by Yi JIANG on 12/3/18.
//  Copyright © 2018 Siphty. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import CoreLocation

class ScenicLocationViewModel {
    
    let disposeBag = DisposeBag()
    var apiClient: ApiClient? = nil
    var locationManager: CLLocationManager? = nil
    var apiResponse = Variable<SLResponse?>(nil)
    var locations = Variable<[Location]>([])
    var isFetchingData = Variable<Bool>(false)
    var isAlertShowing = Variable<Bool>(false)
    private var apiService: ApiService? = nil
    
    init(_ apiService: ApiService) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        locationManager = appDelegate.locationManager
        isFetchingData.value = true
        bindLocations()
        fetchScenicLocation(apiService)
        self.apiService = apiService
    }
    
    func updateScenicLocation() {
        guard let apiService = self.apiService else { return }
        fetchScenicLocation(apiService)
    }
    
    fileprivate func fetchScenicLocation(_ apiService: ApiService) {
        guard let currentLocation = getCurrentLocation() else { return }
        apiService.fetchRestfulApi(ApiConfig.scenicLocations(currentLocation))
            .subscribe(onNext: { status in
                self.isFetchingData.value = false
                switch status {
                case .success(let apiResponse):
                    self.apiResponse.value = apiResponse as? SLResponse
                    self.isAlertShowing.value = false
                case .fail(let error):
                    print(error.errorDescription ?? "Faild to load Scenic Location data")
                    self.isAlertShowing.value = true
                }
            }, onError: { error in
                print(error.localizedDescription)
                self.apiResponse.value = nil
            }, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    fileprivate func bindLocations() {
        apiResponse.asObservable().subscribe(onNext: { apiResponse in
            guard let locations = apiResponse?.locations else { return }
            guard let currentLocation = self.getCurrentLocation() else { return }
            let allLocations = Array(Set(locations + self.locations.value))
            self.locations.value = allLocations.sorted(by: { (location0, location1) -> Bool in
                let clLocation0: CLLocation = CLLocation(latitude: CLLocationDegrees(location0.lat ?? 0.0),
                                                         longitude: CLLocationDegrees(location0.lng ?? 0.0))
                let clLocation1: CLLocation = CLLocation(latitude: CLLocationDegrees(location1.lat ?? 0.0),
                                                         longitude: CLLocationDegrees(location1.lng ?? 0.0))
                return clLocation0.distance(from: currentLocation) < clLocation1.distance(from: currentLocation)
            })
        }, onError: nil, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
}

extension ScenicLocationViewModel {
    
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
