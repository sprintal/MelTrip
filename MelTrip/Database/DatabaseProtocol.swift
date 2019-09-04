//
//  DatabaseProtocol.swift
//  MelTrip
//
//  Created by Kang Meng on 3/9/19.
//  Copyright © 2019 Kang Meng. All rights reserved.
//

import Foundation
enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case locations
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onLocationListChange(change: DatabaseChange, locations: [Location])
}

protocol DatabaseProtocol: AnyObject {
//    var defaultLocation
    func addLocation(name: String, introduction: String, latitude: Double, longtude: Double, image: String) -> Location
    func updateLocation(location: Location)
    func deleteLocation(location: Location)
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}
