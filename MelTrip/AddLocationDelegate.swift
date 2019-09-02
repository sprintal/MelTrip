//
//  AddLocationDelegate.swift
//  MelTrip
//
//  Created by Kang Meng on 2/9/19.
//  Copyright © 2019 Kang Meng. All rights reserved.
//

import Foundation

protocol AddLocationDelegate: AnyObject {
    func addLocation(newLocation: Location) -> Bool
}
