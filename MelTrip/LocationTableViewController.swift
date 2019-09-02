//
//  LocationTableViewController.swift
//  MelTrip
//
//  Created by Kang Meng on 2/9/19.
//  Copyright © 2019 Kang Meng. All rights reserved.
//

import UIKit

class LocationTableViewController: UITableViewController, UISearchResultsUpdating, AddLocationDelegate {
    // TODO
    var allLocations = [Location]()
    var filteredLocations = [Location]()
    weak var locationDelegate: AddLocationDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        createDefaultLocations()
        filteredLocations = allLocations
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search locations"
        navigationItem.searchController = searchController
        
        definesPresentationContext = true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, searchText.count > 0 {
            filteredLocations = allLocations.filter({
                (location: Location) -> Bool in
                return location.name.contains(searchText)
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
        cell.introductionTextView.text = location.introduction

        // Configure the cell...

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // TODO
        tableView.deselectRow(at: indexPath, animated: true)
        return
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createLocatoinSegue" {
            let destionation = segue.destination as! CreateLocationViewController
            destionation.locationDelegate = self
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    
    func addLocation(newLocation: Location) -> Bool {
        allLocations.append(newLocation)
        filteredLocations.append(newLocation)
        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: filteredLocations.count - 1, section: 0)], with: .automatic)
        tableView.endUpdates()
        tableView.reloadSections([0], with: .automatic)
        return true
    }
    
    func createDefaultLocations() {
//        let mapViewController = tabBarController?.children[0] as! MapViewController
        
        var location = Location(name: "Old Melbourne Gaol", introduction: "Step back in time to Melbourne’s most feared destination since 1845, Old Melbourne Gaol.", latitude: -37.8080028, longitude: 144.9629102, image: "")
        allLocations.append(location)
//        mapViewController.mapView.addAnnotation(location)
        
        location = Location(name: "Melbourne Museum", introduction: "A visit to Melbourne Museum is a rich, surprising insight into life in Victoria.", latitude: -37.8031888, longitude: 144.9695788, image: "")
        allLocations.append(location)
//        mapViewController.mapView.addAnnotation(location)
        
        location = Location(name: "Her Majesty's Theatre", introduction: "Her Majesty's Theatre, one of Melbourne's most iconic venues for live performance, has been entertaining Australia since 1886.", latitude: -37.8109121, longitude: 144.9675666, image: "")
        allLocations.append(location)
//        mapViewController.mapView.addAnnotation(location)
    }

}