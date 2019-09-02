//
//  CoreDataController.swift
//  MelTrip
//
//  Created by Kang Meng on 3/9/19.
//  Copyright © 2019 Kang Meng. All rights reserved.
//

import UIKit
import CoreData

class CoreDataController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistantContainer: NSPersistentContainer
    
    // Results
    var allLocationsFetchedResultsController: NSFetchedResultsController<Location>?
    
    override init() {
        persistantContainer = NSPersistentContainer(name: "LocationModel")
        persistantContainer.loadPersistentStores() {
            (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        super.init()
        
        if fetchAllLocations().count == 0 {
            createDefaultEntries()
        }
    }
    
    func saveContext() {
        if persistantContainer.viewContext.hasChanges {
            do {
                try persistantContainer.viewContext.save()
            } catch {
                fatalError("Failed to save data to Core Data: \(error)")
            }
        }
    }
    
    func addLocation(name: String, introduction: String, latitude: Double, longtude: Double, image: String) -> Location {
        let location = NSEntityDescription.insertNewObject(forEntityName: "Location", into: persistantContainer.viewContext) as! Location
        location.name = name
        location.introduction = introduction
        location.latitude = latitude
        location.longitude = longtude
        location.image = image
        saveContext()
        return location
    }
    
    func deleteLocation(location: Location) {
        persistantContainer.viewContext.delete(location)
        saveContext()
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        if listener.listenerType == ListenerType.all || listener.listenerType == ListenerType.locations {
            listener.onLocationListChange(change: .update, locations: fetchAllLocations())
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func fetchAllLocations() -> [Location] {
        if allLocationsFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
            let nameSoreDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSoreDescriptor]
            allLocationsFetchedResultsController = NSFetchedResultsController<Location>(fetchRequest: fetchRequest, managedObjectContext: persistantContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
            allLocationsFetchedResultsController?.delegate = self
            
            do {
                try allLocationsFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request failed: \(error)")
            }
        }
        
        var locations = [Location]()
        if allLocationsFetchedResultsController?.fetchedObjects != nil {
            locations = (allLocationsFetchedResultsController?.fetchedObjects)!
        }
        return locations
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == allLocationsFetchedResultsController {
            listeners.invoke {
                (listener) in
                if listener.listenerType == ListenerType.locations || listener.listenerType == ListenerType.all {
                    listener.onLocationListChange(change: .update, locations: fetchAllLocations())
                }
            }
        }
    }
    
    func createDefaultEntries() {
        let _ = addLocation(name: "Old Melbourne Gaol", introduction: "Step back in time to Melbourne’s most feared destination since 1845, Old Melbourne Gaol.", latitude: -37.8080028, longtude: 144.9629102, image: "")
        let _ = addLocation(name: "Melbourne Museum", introduction: "A visit to Melbourne Museum is a rich, surprising insight into life in Victoria.", latitude: -37.8031888, longtude: 144.9695788, image: "")
        let _ = addLocation(name: "Her Majesty's Theatre", introduction: "Her Majesty's Theatre, one of Melbourne's most iconic venues for live performance, has been entertaining Australia since 1886.", latitude: -37.8109121, longtude: 144.9675666, image: "")
        let _ = addLocation(name: "Chinese Museum", introduction: "Located in the heart of Melbourne’s Chinatown, the Chinese Museum’s five floors showcase the heritage and culture of Australia’s Chinese community.", latitude: -37.810754, longtude: 144.9669807, image: "")
        let _ = addLocation(name: "Parliament of Victoria", introduction: "One of Australia's oldest and most architecturally distinguished public buildings.", latitude: -37.8112679, longtude: 144.9708401, image: "")
        let _ = addLocation(name: "St Paul's Cathedral", introduction: "Leave the bustling Flinders Street Station intersection behind and enter the peaceful place of worship that's been at the heart of city life since the mid 1800s.", latitude: -37.8175442, longtude: 144.9652165, image: "")
        let _ = addLocation(name: "Flinders Street Station", introduction: "Stand beneath the clocks of Melbourne's iconic railway station, as tourists and Melburnians have done for generations.", latitude: -37.8175442, longtude: 144.9652165, image: "")
        let _ = addLocation(name: "Royal Exhibition Building", introduction: "North of the city centre, the majestic Royal Exhibition Building is surrounded by Carlton Gardens.", latitude: -37.8077122, longtude: 144.9709555, image: "")
        let _ = addLocation(name: "Shrine of Remembrance", introduction: "Opened in 1934, the Shrine is the Victorian state memorial to Australians who served in global conflicts throughout our nation’s history.", latitude: -37.8310968, longtude: 144.9745064, image: "")
        let _ = addLocation(name: "Athenaeum Theatre", introduction: "Take a seat for live theatre and music at the Athenaeum Theatre, or climb the grand staircase to the Last Laugh for stand-up comedy on weekends.", latitude: -37.8150343, longtude: 144.9651703, image: "")
        let _ = addLocation(name: "Cooks' Cottage", introduction: "Built in 1755, Cooks' Cottage is the oldest building in Australia and a popular Melbourne tourist attraction.", latitude: -37.814492, longtude: 144.9772522, image: "")
        let _ = addLocation(name: "Fire Services Museum of Victoria", introduction: "An organisation dedicated to the preservation and showcasing of fire-fighting memorabilia from Victoria, Australia and overseas.", latitude: -37.8085374, longtude: 144.9732221, image: "")
        let _ = addLocation(name: "Old Treasury Building", introduction: "The Old Treasury is regarded as one of the finest public buildings in Australia.", latitude: -37.8131629, longtude: 144.9721976, image: "")
        let _ = addLocation(name: "St Patrick's Cathedral", introduction: "Admire the splendid sacristy and chapels within, as well as the floor mosaics and brass items.", latitude: -37.810079, longtude: 144.974228, image: "")
        let _ = addLocation(name: "The Scots' Church", introduction: "Look up to admire the 120-foot spire of the historic Scots' Church, once the highest point of the city skyline.", latitude: -37.8146012, longtude: 144.9663239, image: "")
    }
}
