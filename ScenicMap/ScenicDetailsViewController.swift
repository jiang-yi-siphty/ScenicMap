//
//  ScenicDetailsViewController.swift
//  ScenicMap
//
//  Created by Yi Jiang on 13/3/18.
//  Copyright © 2018 Siphty. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ScenicDetailsViewController: UIViewController {

    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    var scenic: Location? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateDetails()
    }
    
    fileprivate func updateDetails() {
        guard let scenic = scenic else { return }
        guard let lat = scenic.lat else { return }
        guard let lng = scenic.lng else { return }
        latitudeLabel.text = "\(lat)"
        longitudeLabel.text = "\(lng)"
    }
    
}
