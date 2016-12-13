//
//  FlickrConstants.swift
//  VirtualTourist
//
//  Created by André Brinkop on 12.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation

extension FlickrClient {
    
    // MARK: URL Components
    
    struct urlComponents {
        static let scheme = "https"
        static let host = "api.flickr.com"
        static let path = "/services/rest"
    }
    
    // MARK: ParameterKeys
    
    struct parameterKeys {
        static let method = "method"
        static let apiKey = "api_key"
        static let format = "format"
        static let noJSONCallback = "nojsoncallback"
        
        static let bbox = "bbox"
        static let safeSearch = "safe_search"
        static let contentType = "content_type"
        static let geoContext = "geo_context"
        static let extras = "extras"
        static let perPage = "per_page"
        
        static let page = "page"
    }
    
    // MARK: ParameterValues
    
    struct parameterValues {
        static let searchMethod = "flickr.photos.search"
        static let apiKey = Constants.apiKeys.flickr
        static let jsonFormat = "json"
        static let disableJSONCallback = 1
        
        static let useSafeSearch = 1
        static let contentTypePhotos = 1
        static let geoContextOutdoors = 2
        static let mediumURL = "url_m"
        static let defaultPerPage = 250
    }
    
    // MARK: JSONResponseKeys
    
    struct jsonResponseKeys {
        static let status = "stat"
        static let photos = "photos"
        
        static let photo = "photo"
        static let mediumURL = "url_m"
        static let pages = "pages"
    }
    
    // MARK: JSONResponseValues
    
    struct jsonResponseValues {
        static let okStatus = "ok"
    }
    
    // MARK: BBox
    
    struct searchBBox {
        static let halfWidth = 1.0
        static let halfHeight = 1.0
        static let latRange = (-90.0, 90.0)
        static let lonRange = (-180.0, 180.0)
    }
    
    // MARK: Error Messages
    
    struct errorMessages {
        static let apiError = "Internal Flickr API error occurred."
    }
    
}
