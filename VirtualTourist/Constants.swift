//
//  Constants.swift
//  VirtualTourist
//
//  Created by André Brinkop on 12.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    
    // MARK: UI
    
    struct userInterface {
        static let editLabelHeightHidden: CGFloat = 0.0
        static let editLabelHeightShown: CGFloat = 80.0
    }
    
    // MARK: UserDefaults
    
    struct userDefaults {
        static let mapLatitude = "mapLatitude"
        static let mapLongitude = "mapLongitude"
        static let mapLatitudeDelta = "mapLatitudeDelta"
        static let mapLongitudeDelta = "mapLongitudeDelta"
    }
}
