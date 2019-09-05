//
//  LocationTableViewController.swift
//  MelTrip
//
//  Created by Kang Meng on 2/9/19.
//  Copyright © 2019 Kang Meng. All rights reserved.
//

import UIKit

class LocationTableViewController: UITableViewController, UISearchResultsUpdating, /* AddLocationDelegate */DatabaseListener {
    // TODO
    var allLocations = [Location]()
    var filteredLocations = [Location]()
    weak var locationDelegate: AddLocationDelegate?
    weak var databaseController: DatabaseProtocol?
    var alphabeticalFlag = 1
    @IBOutlet weak var barButton: UIBarButtonItem!
    
    weak var chooseLocationDelegate: ChooseLocationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search locations"
        navigationItem.searchController = searchController
        
        definesPresentationContext = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.5) {
            self.navigationController?.navigationBar.barTintColor = UIColor.white
            self.navigationController?.navigationBar.layoutIfNeeded()
        }
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    var listenerType: ListenerType = ListenerType.locations
    
    func onLocationListChange(change: DatabaseChange, locations: [Location]) {
        allLocations = locations
        updateSearchResults(for: navigationItem.searchController!)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, searchText.count > 0 {
            filteredLocations = allLocations.filter({
                (location: Location) -> Bool in
                return location.name!.contains(searchText)
            })
        }
        else {
            filteredLocations = allLocations
        }
        
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return filteredLocations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "locationCell", for: indexPath) as! LocationTableViewCell
        let location = filteredLocations[indexPath.row]
        cell.nameLabel.text = location.name
        cell.introductionLabel.text = location.introduction
        if location.image != "" {
            if Int(location.image!) != nil {
                cell.locationImage.image = loadImageData(fileName: location.image!)
            } else {
                cell.locationImage.image = UIImage(named: location.image ?? "placeholder")
            }
        } else {
            cell.locationImage.image = UIImage(named: "placeholder")
        }
        
        let backgroundColor: UIColor
        switch location.type {
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
        cell.backgroundColor = backgroundColor
        // Configure the cell...
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO
        tableView.deselectRow(at: indexPath, animated: true)
        chooseLocationDelegate?.centerOnChosen(index: allLocations.firstIndex(of: filteredLocations[indexPath.row])!)
        navigationController?.popViewController(animated: true)
        return
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            databaseController?.deleteLocation(location: filteredLocations[indexPath.row])
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createLocatoinSegue" {
            let destionation = segue.destination as! CreateLocationViewController
            destionation.locationDelegate = self
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    /// Alphabatically sort locations on bar button item click
    ///
    /// - Parameter sender:
    @IBAction func barButton(_ sender: Any) {
        if alphabeticalFlag == 0 {
            filteredLocations = filteredLocations.sorted { $0.name! < $1.name! }
            alphabeticalFlag = 1
            barButton.title = "Z-A"
        } else if alphabeticalFlag == 1 {
            filteredLocations = filteredLocations.sorted { $0.name! > $1.name! }
            alphabeticalFlag = 0
            barButton.title = "A-Z"
        }
        tableView.reloadData()
    }
    
    /// Load image from storage
    ///
    /// - Parameter fileName: The location's image's file name
    /// - Returns: The image of the location
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
}
