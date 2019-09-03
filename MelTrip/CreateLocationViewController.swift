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

class CreateLocationViewController: UIViewController, UIGestureRecognizerDelegate, MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate {
//    weak var locationDelegate: AddLocationDelegate?
    weak var databaseController: DatabaseProtocol?
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var introductionTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    //    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    //    @IBOutlet weak var introductionTextField: UITextField!
//    @IBOutlet weak var mapView: MKMapView!
    var locationAnnotation: MKPointAnnotation?
//    let motionManager: CMMotionManager = CMMotionManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        introductionTextView.layer.borderWidth = 1
        introductionTextView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        introductionTextView.layer.cornerRadius = 5.0
        // Center the map to Melbourne CBD
        // Inspired from https://hangge.com/blog/cache/detail_1878.html
        self.mapView.delegate = self
        self.nameTextField.delegate = self
        self.introductionTextView.delegate = self
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
    
    @IBAction func takePhoto(_ sender: Any) {
        let controller = UIImagePickerController()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            controller.sourceType = .camera
        } else {
            controller.sourceType = .photoLibrary
        }
        controller.allowsEditing = false
        controller.delegate = self
        self.present(controller, animated: true, completion: nil)
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
        if nameTextField.text != "" && introductionTextView.text != "" && locationAnnotation != nil  && imageView.image != nil && imageView.image != UIImage(named: "placeholder") {
            let name = nameTextField.text!
            let introduction = introductionTextView.text!
            let latitude = locationAnnotation!.coordinate.latitude
            let longitude = locationAnnotation!.coordinate.longitude
            let image = imageView.image
            let date = UInt(Date().timeIntervalSince1970)
            var data = Data()
            data = image!.jpegData(compressionQuality: 0.8)!
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
            let url = NSURL(fileURLWithPath: path)
            if let pathComponent = url.appendingPathComponent("\(date)") {
                let filePath = pathComponent.path
                let fileManager = FileManager.default
                fileManager.createFile(atPath: filePath, contents: data, attributes: nil)
            }
            
//            let location = Location(name: name, introduction: introduction, latitude: latitude, longitude: longitude, image: image)
//            let _ = locationDelegate!.addLocation(newLocation: location)
            let _ = databaseController!.addLocation(name: name, introduction: introduction, latitude: latitude, longtude: longitude, image: String(date))
            print("added")
            navigationController?.popViewController(animated: true)
            return
        }
        var errorMsg = "Please ensure all info has been provided!"
        if (nameTextField.text == "") {
            errorMsg.append("\n- Please enter a name")
        }
        if (introductionTextView.text == "") {
            errorMsg.append("\n- Please enter introduction")
        }
        if (locationAnnotation == nil) {
            errorMsg.append("\n- Please choose a locatin on the map")
        }
        if (imageView.image == nil || imageView.image == UIImage(named: "placeholder")) {
            errorMsg.append("\n- Please choose a photo for the location")
        }
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            imageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("Error when getting the image")
        dismiss(animated: true, completion: nil)	
    }
    
    
    // Limit the number of characters
    // Code from https://www.hackingwithswift.com/example-code/uikit/how-to-limit-the-number-of-characters-in-a-uitextfield-or-uitextview
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        let changedText = currentText.replacingCharacters(in: stringRange, with: text)
        return changedText.count <= 300
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else {
            return false
        }
        let changedText = currentText.replacingCharacters(in: stringRange, with: string)
        return changedText.count <= 100
    }
}

