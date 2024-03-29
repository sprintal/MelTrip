//
//  EditLocationViewController.swift
//  MelTrip
//
//  Created by Kang Meng on 5/9/19.
//  Copyright © 2019 Kang Meng. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class EditLocationViewController: UIViewController, UIGestureRecognizerDelegate, MKMapViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UITextFieldDelegate {
    weak var databaseController: DatabaseProtocol?
    var location: Location?
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var introductionTextView: UITextView!
    @IBOutlet weak var mapView: MKMapView!
    var locationAnnotation: MKPointAnnotation?
    weak var updateLocationDelegate: UpdateLocationDelegate?
    var imageChanged = false
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var takePhotoButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        introductionTextView.layer.borderWidth = 1
        introductionTextView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        introductionTextView.layer.cornerRadius = 5.0
        // Do any additional setup after loading the view.
        self.mapView.delegate = self
        self.nameTextField.delegate = self
        self.introductionTextView.delegate = self
        
        self.locationAnnotation = MKPointAnnotation()
        self.locationAnnotation!.coordinate = CLLocationCoordinate2D(latitude: location!.latitude, longitude: location!.longitude)
        self.mapView.addAnnotation(locationAnnotation!)
        
        self.nameTextField.text = location?.name
        self.introductionTextView.text = location?.introduction
        self.typeSegmentedControl.selectedSegmentIndex = Int(location!.type)
        
        // Add Done button to toolbar
        // From http://www.swiftdevcenter.com/uitextview-dismiss-keyboard-swift/
        self.introductionTextView.addDoneButton(title: "Done", target: self, selector: #selector(tapDone(sender:)))
        
        if (location!.image != "") {
            if Int(location!.image!) != nil {
                imageView.image = loadImageData(fileName: location!.image!)
            } else {
                imageView.image = UIImage(named: location!.image ?? "placeholder")
            }
        } else {
            imageView.image = UIImage(named: "placeholder")
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        let zoomRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location!.latitude, longitude: location!.longitude), latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
        
        // Tap gesture on map
        // Modified from https://stackoverflow.com/a/53885008
        let gestureRecoginzer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        gestureRecoginzer.delegate = self
        mapView.addGestureRecognizer(gestureRecoginzer)
        segmentedControlChanged()
        self.typeSegmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        if nameTextField.text != "" && introductionTextView.text != "" && locationAnnotation != nil  && imageView.image != nil && imageView.image != UIImage(named: "placeholder") {
            let name = nameTextField.text!
            let introduction = introductionTextView.text!
            let latitude = locationAnnotation!.coordinate.latitude
            let longitude = locationAnnotation!.coordinate.longitude
            let type = Int16(typeSegmentedControl.selectedSegmentIndex)
            
            if imageChanged {
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
                location?.image = String(date)
            }
            location?.name = name
            location?.introduction = introduction
            location?.latitude = latitude
            location?.longitude = longitude
            location?.type = type
            databaseController?.updateLocation(location: location!)
            self.dismiss(animated: true, completion: nil)
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
            errorMsg.append("\n- Please choose a location on the map")
        }
        if (imageView.image == nil || imageView.image == UIImage(named: "placeholder")) {
            errorMsg.append("\n- Please choose a photo for the location")
        }
        displayMessage(title: "Not all fields filled", message: errorMsg)
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
    
    // Show annotation when tap on map
    // Modified from https://stackoverflow.com/a/53885008
    @objc func handleTap(sender: UITapGestureRecognizer) {
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
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            imageView.image = pickedImage
            self.imageChanged = true
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
    
    func displayMessage(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.resignFirstResponder()
    }
    
    /// Dismiss keyboard on Done button click
    /// From http://www.swiftdevcenter.com/uitextview-dismiss-keyboard-swift/
    ///
    /// - Parameter sender:
    @objc func tapDone(sender: Any) {
        self.view.endEditing(true)
    }
    
    @objc func segmentedControlChanged() {
        let value = self.typeSegmentedControl.selectedSegmentIndex
        switch value {
        case 0:
            UIView.animate(withDuration: 0.5) {
                self.typeSegmentedControl.tintColor = UIColor.defaultColor
                self.takePhotoButton.tintColor = UIColor.defaultColor
            }
        case 1:
            UIView.animate(withDuration: 0.5) {
                self.typeSegmentedControl.tintColor = UIColor.museumColor
                self.takePhotoButton.tintColor = UIColor.museumColor
            }
        case 2:
            UIView.animate(withDuration: 0.5) {
                self.typeSegmentedControl.tintColor = UIColor.parkColor
                self.takePhotoButton.tintColor = UIColor.parkColor
            }
        case 3:
            UIView.animate(withDuration: 0.5) {
                self.typeSegmentedControl.tintColor = UIColor.historicalColor
                self.takePhotoButton.tintColor = UIColor.historicalColor
            }
        default:
            return
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
