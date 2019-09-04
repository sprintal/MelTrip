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
import UserNotifications

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, DatabaseListener, ChooseLocationDelegate {
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
        updateAnnotations(locations: allLocations)
        updateGeoLocations()
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
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "mapTableSegue" {
            let destination = segue.destination as! LocationTableViewController
            destination.chooseLocationDelegate = self
        }
    }

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
        let state = UIApplication.shared.applicationState
        if state == .active {
            let alert = UIAlertController(title: "Movement detected", message: "You entered \(region.identifier)", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if state == .background || state == .inactive {
            let content = UNMutableNotificationContent()
            content.title = "Movement detected"
            content.body = "Welcome to " + region.identifier
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
            let request = UNNotificationRequest(identifier: "geoFence", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        let state = UIApplication.shared.applicationState
        if state == .active {
            let alert = UIAlertController(title: "Movement detected", message: "You left \(region.identifier)", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else if state == .background || state == .inactive {
            let content = UNMutableNotificationContent()
            content.title = "Movement detected"
            content.body = "You left " + region.identifier
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
            let request = UNNotificationRequest(identifier: "geoFence", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
    //Modified from https://stackoverflow.com/a/41187788
//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//        let detailViewController = self.storyboard?.instantiateViewController(withIdentifier: "detailViewController") as! DetailViewController
//        let index = locationAnnotations.firstIndex(of: view.annotation as! LocationAnnotation)
//        detailViewController.location = allLocations[index!]
//        self.present(detailViewController, animated: true, completion: nil)
//    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is LocationAnnotation) {
            return nil
        }
        let resueId = annotation.title!
        var anView = mapView.dequeueReusableAnnotationView(withIdentifier: resueId!)
        if anView == nil {
            anView = MKAnnotationView(annotation: annotation, reuseIdentifier: resueId)
            let size = CGSize(width: 40, height: 40)
            let location: Location = allLocations[locationAnnotations.firstIndex(of: annotation as! LocationAnnotation)!]
            var pinImage: UIImage
            if Int(location.image!) == nil {
                let fileName = location.image!
                pinImage = UIImage(named: fileName)!
            } else {
                let fileName = location.image
                print(location)
                pinImage = loadImageData(fileName: fileName!)!
            }
            UIGraphicsBeginImageContext(size)
            pinImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            anView?.image = resizedImage
//            let subtitleView = UIButton()
//            subtitleView.titleLabel?.text = "click"
//            anView?.rightCalloutAccessoryView = subtitleView
            var button = UIButton(type: .detailDisclosure)
            anView?.rightCalloutAccessoryView = button
            anView!.canShowCallout = true
            anView!.isEnabled = true
        }
        return anView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            // Modified from https://stackoverflow.com/a/41187788
            let detailViewController = self.storyboard?.instantiateViewController(withIdentifier: "detailViewController") as! DetailViewController
            let index = locationAnnotations.firstIndex(of: view.annotation as! LocationAnnotation)
            detailViewController.location = allLocations[index!]
            self.present(detailViewController, animated: true, completion: nil)
        }
    }
    
    func loadImageData(fileName: String) -> UIImage? {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let url = NSURL(fileURLWithPath: path)
        var image: UIImage?
        if let pathComponent = url.appendingPathComponent(fileName) {
            let filePath = pathComponent.path
            let fileManager = FileManager.default
            let fileData = fileManager.contents(atPath: filePath)
            image = UIImage(data: fileData!)
        }
        return image
    }
    
    func centerOnChosen(index: Int) {
        print(index)
        let zoomRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: allLocations[index].latitude, longitude: allLocations[index].longitude), latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
    }
}
