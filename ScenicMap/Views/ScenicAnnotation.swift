//
//  ScenicAnnotation.swift
//  ScenicMap
//
//  Created by Yi Jiang on 13/3/18.
//  Copyright © 2018 Siphty. All rights reserved.
//

import MapKit
import Foundation

open class ScenicAnnotation: MKPointAnnotation {
    var scenicLocation: CLLocation?
    var name: String?
    var scenic: Location?
    
    init(_ scenic: Location) {
        super.init()
        self.scenic = scenic
        guard let lat = scenic.lat else { return }
        guard let lng = scenic.lng else { return }
        let scenicLocation = CLLocation(latitude: CLLocationDegrees(lat),
                                        longitude: CLLocationDegrees(lng))
        self.scenicLocation = scenicLocation
        title = scenic.name
        subtitle = "Latitude:\(lat)\nLongitude:\(lng)"
        coordinate = scenicLocation.coordinate
    }
    
    
}
