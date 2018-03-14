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
import RxMKMapView
import CoreLocation
import MapKit
import ObjectMapper

class ScenicMapViewController: UIViewController {
    
    @IBOutlet var scenicMapView: MKMapView!
    @IBOutlet weak var refreshBarbuttonItem: UIBarButtonItem!
    let disposeBag = DisposeBag()
    var locationManager: CLLocationManager? = nil
    var slViewModel: ScenicLocationViewModel? {
        didSet {
            bindScneicLocationViewModel()
        }
    }
    var csViewModel: CustomScenicViewModel? {
        didSet {
            bindCustomScenicViewModel()
        }
    }
    var selectedAnnotation: ScenicAnnotation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        locationManager = appDelegate.locationManager
        slViewModel = ScenicLocationViewModel(ApiClient())
        csViewModel = CustomScenicViewModel()
        scenicMapView.showsUserLocation = true
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(locationManagerDidUpdateLocation(_ :)),
                                               name: NSNotification.Name(rawValue: Notification.didUpdateLocations),
                                               object: nil)
        let longPressRecogniser = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressRecogniser.minimumPressDuration = 1.0
        scenicMapView.addGestureRecognizer(longPressRecogniser)
    }
    
    private func bindScneicLocationViewModel(){
        slViewModel?.locations.asObservable().subscribe(onNext: { locations in
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
            self.slViewModel?.updateScenicLocation()
            self.csViewModel?.fetchCustomScenic()
        }, onError: { error in
            print("error: \(error.localizedDescription)")
        }, onCompleted: nil, onDisposed: nil).disposed(by: disposeBag)
    }
    
    
    private func bindCustomScenicViewModel(){
        csViewModel?.locations.asObservable().subscribe(onNext: { locations in
            let annotations = locations.map({ location -> ScenicAnnotation in
                let annotation = ScenicAnnotation(location)
                return annotation
            })
            DispatchQueue.main.async {
                self.scenicMapView.addAnnotations(annotations)
            }
        }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
        
        
    }
}

extension ScenicMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
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
                destinationVC.title = selectedAnnotation.scenic?.name
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
    
    @objc func handleLongPress(_ gestureRecognizer : UIGestureRecognizer){
        if gestureRecognizer.state != .began { return }
        let touchPoint = gestureRecognizer.location(in: scenicMapView)
        let touchMapCoordinate = scenicMapView.convert(touchPoint, toCoordinateFrom: scenicMapView)
        let clLocation = CLLocation(latitude: touchMapCoordinate.latitude,
                                    longitude: touchMapCoordinate.longitude)
        //MARK: Alert Controller for user type in custom scenic's name
        let addNewAnnotationAlert = UIAlertController(title: "Add New Scenic", message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        addNewAnnotationAlert.addAction(cancelAction)
        addNewAnnotationAlert.addTextField { newScenicNameTextField in
            newScenicNameTextField.placeholder = "Enter Scenic Name"
        }
        let saveAction = UIAlertAction(title: "Save Scenic", style: .default) { alert in
            let textField = addNewAnnotationAlert.textFields![0] as UITextField
            guard let textFieldText = textField.text else { return }
            let loc = ["lat": Float(clLocation.coordinate.latitude), "lng": Float(clLocation.coordinate.longitude), "name": textFieldText, "comment": ""] as [String : Any]
            guard let scenic = Mapper<Location>().map(JSON: loc) else { return }
            CustomScenicViewModel().addCustomScenic(scenic)
            let userAddedAnnotation = ScenicAnnotation(scenic)
            self.scenicMapView.addAnnotation(userAddedAnnotation)
        }
        addNewAnnotationAlert.addAction(saveAction)
        self.present(addNewAnnotationAlert, animated: true, completion: nil)
    }
    

}


