//
//  Location.swift
//  MelTrip
//
//  Created by Kang Meng on 2/9/19.
//  Copyright © 2019 Kang Meng. All rights reserved.
//

import UIKit

class Location: NSObject {
    var name: String
    var introduction: String
    var latitude: Double
    var longitude: Double
    var image: String
    
    init(name: String, introduction: String, latitude: Double, longitude: Double, image: String) {
        self.name = name
        self.introduction = introduction
        self.latitude = latitude
        self.longitude = longitude
        self.image = image
    }
}
