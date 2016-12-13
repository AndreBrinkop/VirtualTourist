//
//  ApiKeys.swift
//  VirtualTourist
//
//  Created by André Brinkop on 13.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation

func getAPIKey(_ name: String) -> String {
    guard let plistPath = Bundle.main.path(forResource: Constants.apiKeys.plistName, ofType: "plist") else {
        fatalError("Could not find \"\(Constants.apiKeys.plistName).plist\" file")
    }
    
    let plist = NSDictionary(contentsOfFile:plistPath)
    
    guard let apiKey = plist?.object(forKey: name) as? String else {
        fatalError("Could not find API key named \"\(name)\" in the \"\(Constants.apiKeys.plistName).plist\" file")
    }
    
    return apiKey
}
