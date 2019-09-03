//
//  MapViewController.swift
//  MelTrip
//
//  Created by Kang Meng on 3/9/19.
//  Copyright © 2019 Kang Meng. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, DatabaseListener {
    @IBOutlet weak var mapView: MKMapView!
    
    var allLocations = [Location]()
    var locationAnnotations = [LocationAnnotation]()
    var geoLocations = [CLCircularRegion]()
    weak var databaseController: DatabaseProtocol?
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        // Do any additional setup after loading the view.
        
        // Center the map to Melbourne CBD
        // Inspired from https://hangge.com/blog/cache/detail_1878.html
        self.mapView.delegate = self
        let centerLocationSpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let center:CLLocation = CLLocation(latitude: -37.8136, longitude: 144.9631)
        let centerRegion: MKCoordinateRegion = MKCoordinateRegion(center: center.coordinate, span: centerLocationSpan)
        self.mapView.setRegion(centerRegion, animated: true)
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
        databaseController?.addListener(listener: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.startUpdatingLocation()
        databaseController?.removeListener(listener: self)
    }
    
    var listenerType: ListenerType = ListenerType.locations
    
    func onLocationListChange(change: DatabaseChange, locations: [Location]) {
        self.allLocations = locations
        updateAnnotations(locations: allLocations)
        updateGeoLocations()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location.coordinate
        }
    }
    
    // TODO
//    func focusOn(index: Int) {
//        print(index)
//        let annotation = locationAnnotations[index]
//        mapView.selectAnnotation(annotation, animated: true)
//
//        let zoomRegion = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
//        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
//    }
    
    @IBAction func currentLocation(_ sender: Any) {
        guard let location = currentLocation else {
            return
        }
        
        let zoomRegion = MKCoordinateRegion(center: location, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    func updateAnnotations(locations: [Location]) {
        self.locationAnnotations = []
        for location in locations {
            self.locationAnnotations.append(LocationAnnotation(title: location.name!, subtitle: location.introduction!, latitude: location.latitude, longitude: location.longitude))
        }
        self.mapView.removeAnnotations(mapView.annotations)
        self.mapView.addAnnotations(self.locationAnnotations)
//        for locationAnnotation in self.locationAnnotations {
//            let anView = mapView.view(for: locationAnnotation)
//                anView.image = #imageLiteral(resourceName: "Old Melbourne Gaol")
//        }
    }
    
    func updateGeoLocations() {
        print("update")
        for geoLocation in self.geoLocations {
            locationManager.stopMonitoring(for: geoLocation)
        }
        self.geoLocations = []
        var geoLocation: CLCircularRegion
        for location in self.allLocations {
            geoLocation = CLCircularRegion(center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude), radius: 100, identifier: location.name!)
            geoLocation.notifyOnExit = true
            geoLocation.notifyOnEntry = true
            self.geoLocations.append(geoLocation)
            locationManager.startMonitoring(for: geoLocation)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        let alert = UIAlertController(title: "Movement detected", message: "You entered \(region.identifier)", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let alert = UIAlertController(title: "Movement detected", message: "You left \(region.identifier)", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //Modified from https://stackoverflow.com/a/41187788
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let detailViewController = self.storyboard?.instantiateViewController(withIdentifier: "detailViewController") as! DetailViewController
        let index = locationAnnotations.firstIndex(of: view.annotation as! LocationAnnotation)
        detailViewController.location = allLocations[index!]
        self.present(detailViewController, animated: true, completion: nil)
    }

//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        if !(annotation is MKPointAnnotation) {
//            return nil
//        }
//        let annotationIndetifier = "AnnotationIdentifier"
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIndetifier)
//        
//        if annotationView == nil {
//            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIndetifier)
//            annotationView!.canShowCallout = true
//        } else {
//            annotationView!.annotation = annotation
//        }
//        
//        let image = #imageLiteral(resourceName: "Old Melbourne Gaol")
//        annotationView!.image = image
//        return annotationView
//    }
}
