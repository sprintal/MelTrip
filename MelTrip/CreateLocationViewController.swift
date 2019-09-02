//
//  CreateLocationViewController.swift
//  MelTrip
//
//  Created by Kang Meng on 2/9/19.
//  Copyright © 2019 Kang Meng. All rights reserved.
//

import UIKit
import MapKit
import CoreMotion

class CreateLocationViewController: UIViewController, UIGestureRecognizerDelegate, MKMapViewDelegate {
//    weak var locationDelegate: AddLocationDelegate?
    weak var databaseController: DatabaseProtocol?
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var introductionTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    var locationAnnotation: MKPointAnnotation?
//    let motionManager: CMMotionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Center the map to Melbourne CBD
        // Inspired from https://hangge.com/blog/cache/detail_1878.html
        self.mapView.delegate = self
        let centerLocationSpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let center:CLLocation = CLLocation(latitude: -37.8136, longitude: 144.9631)
        let centerRegion: MKCoordinateRegion = MKCoordinateRegion(center: center.coordinate, span: centerLocationSpan)
        self.mapView.setRegion(centerRegion, animated: true)
        
        let appDelegate = UIApplication.shared .delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        // Do any additional setup after loading the view.
        
        // Tap gesture on map
        // Modified from https://stackoverflow.com/a/53885008
        let gestureRecoginzer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        gestureRecoginzer.delegate = self
        mapView.addGestureRecognizer(gestureRecoginzer)
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    @IBAction func saveLocation(_ sender: Any) {
        if nameTextField.text != "" && introductionTextField.text != "" && locationAnnotation != nil {
            let name = nameTextField.text!
            let introduction = introductionTextField.text!
            let latitude = locationAnnotation!.coordinate.latitude
            let longitude = locationAnnotation!.coordinate.longitude
            let image = ""
//            let location = Location(name: name, introduction: introduction, latitude: latitude, longitude: longitude, image: image)
//            let _ = locationDelegate!.addLocation(newLocation: location)
            let _ = databaseController!.addLocation(name: name, introduction: introduction, latitude: latitude, longtude: longitude, image: image)
            navigationController?.popViewController(animated: true)
            return
        }
        let errorMsg = "Please ensure all info has been provided!"
        displayMessage(title: "Not all fields filled", message: errorMsg)
    }
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Modified from https://stackoverflow.com/a/53885008
    @objc func handleTap(sender: UITapGestureRecognizer) {
        print("tapped")
        if locationAnnotation != nil {
            self.mapView.removeAnnotation(locationAnnotation!)
        }
        let locationInView = sender.location(in: mapView)
        let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
        addAnnotation(location: locationOnMap)
    }
    
    // Modified from https://stackoverflow.com/a/53885008
    func addAnnotation(location: CLLocationCoordinate2D) {
        locationAnnotation = MKPointAnnotation()
        locationAnnotation!.coordinate = location
        self.mapView.addAnnotation(locationAnnotation!)
        print(locationAnnotation!.coordinate.latitude)
        print(locationAnnotation!.coordinate.longitude)
    }
    
}

