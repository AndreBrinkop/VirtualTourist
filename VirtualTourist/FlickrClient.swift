//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by André Brinkop on 12.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation
import UIKit

class FlickrClient {
    
    // MARK: Retrieve a picture
    
    func getImageForPath(path: URL, completionHandler: @escaping (_ image: UIImage?, _ error: Error?) -> ()) {
        
        HTTPClient.getRequest(url: path, headerFields: nil) { data, error in
            
            guard let data = data, error == nil else {
                completionHandler(nil, error)
                return
            }
            
            completionHandler(UIImage(data: data), nil)
        }
    }
}
