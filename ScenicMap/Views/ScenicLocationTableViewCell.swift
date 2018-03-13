//
//  ScenicLocationTableViewCell.swift
//  ScenicMap
//
//  Created by Yi Jiang on 13/3/18.
//  Copyright © 2018 Siphty. All rights reserved.
//

import UIKit
import CoreLocation

class ScenicLocationTableViewCell: UITableViewCell {
    @IBOutlet weak var scenicName: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    var scenic: Location? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }

    static func reuseId() -> String {
        return String(describing: self)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    func configureCell(_ scenic: Location?) {
        guard let scenic = scenic else { return }
        scenicName.text = scenic.name
        self.scenic = scenic
        updateDistanceLabel(scenic)
    }
    
    fileprivate func updateDistanceLabel(_ scenic: Location) {
        guard let lat = scenic.lat else { return }
        guard let lng = scenic.lng else { return }
        let clLocation = CLLocation(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lng))
        guard let userLocation = getCurrentLocation() else { return }
        let distance = userLocation.distance(from: clLocation)
        self.distanceLabel.text = String(format: "%.1f km", (distance / 1000))
    }
    
    fileprivate func getCurrentLocation() -> CLLocation? {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let locationManager = appDelegate.locationManager
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
