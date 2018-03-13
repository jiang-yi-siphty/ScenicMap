//
//  ScenicMapViewController.swift
//  ScenicMap
//
//  Created by Yi Jiang on 13/3/18.
//  Copyright © 2018 Siphty. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation
import MapKit

class ScenicMapViewController: UIViewController {
    
    @IBOutlet var scenicMapView: MKMapView!
    @IBOutlet weak var refreshBarbuttonItem: UIBarButtonItem!
    let disposeBag = DisposeBag()
    var locationManager: CLLocationManager? = nil
    var viewModel: ScenicLocationViewModel? {
        didSet {
            bindViewModel()
        }
    }
    var selectedAnnotation: ScenicAnnotation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        locationManager = appDelegate.locationManager
        viewModel = ScenicLocationViewModel(ApiClient())
        scenicMapView.showsUserLocation = true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(locationManagerDidUpdateLocation(_ :)),
                                               name: NSNotification.Name(rawValue: Notification.didUpdateLocations),
                                               object: nil)
    }
    
    private func bindViewModel(){
        viewModel?.locations.asObservable().subscribe(onNext: { locations in
            let annotations = locations.map({ location -> ScenicAnnotation in
                let annotation = ScenicAnnotation(location)
                return annotation
            })
            DispatchQueue.main.async {
                self.scenicMapView.addAnnotations(annotations)
                self.scenicMapView.showAnnotations(annotations, animated: true)
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        refreshBarbuttonItem.rx.tap.asObservable().subscribe(onNext: { () in
            self.clearAnnotation()
            self.viewModel?.updateScenicLocation()
        }, onError: { error in
            print("error: \(error.localizedDescription)")
        }, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
}

extension ScenicMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("did select!!!!!!!!!!!!!!")
        selectedAnnotation = view.annotation as! ScenicAnnotation
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotationView")
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = UIButton.init(type: UIButtonType.detailDisclosure)
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("callout accessary ")
        self.performSegue(withIdentifier: "ShowMapDetailsViewSegue", sender: self)
    }

}

extension ScenicMapViewController {
    @objc func locationManagerDidUpdateLocation(_ notification: NSNotification) {
        if let userDict = notification.userInfo, let currentLocation = userDict["location"] as? CLLocation {
        }
    }
    
    func centerMapOnLocation(_ location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 5000, 5000)
        scenicMapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowMapDetailsViewSegue" {
            if let destinationVC = segue.destination as? ScenicDetailsViewController {
                guard let selectedAnnotation = selectedAnnotation else { return }
                destinationVC.scenic = selectedAnnotation.scenic
                destinationVC.title = selectedAnnotation.name
            }
        }
    }
    
    func clearAnnotation(){
        let _ = scenicMapView.annotations.map { annotation in
            if annotation is ScenicAnnotation {
                let annotation = annotation as! ScenicAnnotation
                scenicMapView.removeAnnotation(annotation)
            }
        }
    }
}
