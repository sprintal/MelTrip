//
//  CreateLocationViewController.swift
//  MelTrip
//
//  Created by Kang Meng on 2/9/19.
//  Copyright © 2019 Kang Meng. All rights reserved.
//

import UIKit
import MapKit

class CreateLocationViewController: UIViewController {
//    weak var locationDelegate: AddLocationDelegate?
    weak var databaseController: DatabaseProtocol?
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var introductionTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared .delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        // Do any additional setup after loading the view.
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
        if nameTextField.text != "" && introductionTextField.text != "" {
            let name = nameTextField.text!
            let introduction = introductionTextField.text!
            let latitude = 0.0
            let longitude = 0.0
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
}

