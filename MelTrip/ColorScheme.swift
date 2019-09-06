//
//  ColorScheme.swift
//  MelTrip
//
//  Created by Kang Meng on 5/9/19.
//  Copyright © 2019 Kang Meng. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    class var defaultColor: UIColor {
        return UIColor(red: 121/255, green: 151/255, blue: 155/255, alpha: 1.0)
    }
    
    class var parkColor: UIColor {
        return UIColor(red: 48/255, green: 209/255, blue: 88/255, alpha: 1.0)
    }
    
    class var historicalColor: UIColor {
        return UIColor(red: 255/255, green: 159/255, blue: 10/255, alpha: 1.0)
    }
    
    class var museumColor: UIColor {
        return UIColor(red: 255/255, green: 55/255, blue: 95/255, alpha: 1.0)
    }
    
    class var defaultBackgroundColor: UIColor {
        return UIColor(red: 121/255, green: 151/255, blue: 155/255, alpha: 0.95)
    }
    
    class var parkBackgroundColor: UIColor {
        return UIColor(red: 48/255, green: 209/255, blue: 88/255, alpha: 0.95)
    }
    
    class var historicalBackgroundColor: UIColor {
        return UIColor(red: 255/255, green: 159/255, blue: 10/255, alpha: 0.95)
    }
    
    class var museumBackgroundColor: UIColor {
        return UIColor(red: 255/255, green: 55/255, blue: 95/255, alpha: 0.95)
    }

    class var defaultCellBackgroundColor: UIColor {
        return UIColor(red: 121/255, green: 151/255, blue: 155/255, alpha: 0.4)
    }
    
    class var parkCellBackgroundColor: UIColor {
        return UIColor(red: 48/255, green: 209/255, blue: 88/255, alpha: 0.4)
    }
    
    class var historicalCellBackgroundColor: UIColor {
        return UIColor(red: 255/255, green: 159/255, blue: 10/255, alpha: 0.4)
    }
    
    class var museumCellBackgroundColor: UIColor {
        return UIColor(red: 255/255, green: 55/255, blue: 95/255, alpha: 0.4)
    }
}
