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
    
    // MARK: Defaults
    
    struct defaults {
        static let photoAlbumSize = 30
    }
    
    // MARK: UserDefaults
    
    struct userDefaults {
        static let mapLatitude = "mapLatitude"
        static let mapLongitude = "mapLongitude"
        static let mapLatitudeDelta = "mapLatitudeDelta"
        static let mapLongitudeDelta = "mapLongitudeDelta"
    }
    
    // MARK: API Keys
    
    private struct apiKeyNames {
        static let flickr = "FLICKR_API_KEY"
    }
    
    struct apiKeys {
        static let plistName = "ApiKeys"
        static let flickr = getAPIKey(apiKeyNames.flickr)
    }
}
