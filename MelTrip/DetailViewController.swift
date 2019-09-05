//
//  DetailViewController.swift
//  MelTrip
//
//  Created by Kang Meng on 3/9/19.
//  Copyright © 2019 Kang Meng. All rights reserved.
//

import UIKit
import MapKit

class DetailViewController: UIViewController, UpdateLocationDelegate {
    var location: Location?
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var introductionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nameLabel.text = location!.name
        introductionLabel.text = location!.introduction
        if (location!.image != "") {
            if Int(location!.image!) != nil {
                imageView.image = loadImageData(fileName: location!.image!)
            } else {
                imageView.image = UIImage(named: location!.image ?? "placeholder")
            }
        } else {
            imageView.image = UIImage(named: "placeholder")
        }
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(LocationAnnotation(title: location!.name!, subtitle: location!.introduction!, latitude: location!.latitude, longitude: location!.longitude, type: location!.type))
        let zoomRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location!.latitude, longitude: location!.longitude), latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
        
        let backgroundColor: UIColor
        switch location!.type {
        case 0:
            backgroundColor = UIColor.defaultBackgroundColor
        case 1:
            backgroundColor = UIColor.museumBackgroundColor
        case 2:
            backgroundColor = UIColor.parkBackgroundColor
        case 3:
            backgroundColor = UIColor.historicalBackgroundColor
        default:
            backgroundColor = UIColor.white
        }
        nameLabel.backgroundColor = backgroundColor
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "updateLocationSegue" {
            let destination = segue.destination as! EditLocationViewController
            destination.location = self.location
            destination.updateLocationDelegate = self
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateLocation(location: Location) {
        self.location = location
    }
}
