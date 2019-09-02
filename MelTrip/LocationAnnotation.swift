//
//  LocationAnnotation.swift
//  MelTrip
//
//  Created by Kang Meng on 3/9/19.
//  Copyright © 2019 Kang Meng. All rights reserved.
//

import UIKit
import MapKit

class LocationAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(title: String, subtitle: String, latitude: Double, longitude: Double) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
