//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by André Brinkop on 12.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import GameKit

class FlickrClient {
    
    // MARK: Retrieve picture URLs for location
    
    static func getImageURLsForLocation(coordinate: CLLocationCoordinate2D, completionHandler: @escaping (_ urls: [URL]?, _ error: Error?) -> ()) {
        let completionHandlerMainThread: (_ urls: [URL]?, _ error: Error?) -> () = { urls, error in
            DispatchQueue.main.async {
                completionHandler(urls, error)
            }
        }
        
        let searchURL = createGetImageURLsForLocationURL(coordinate: coordinate, page: 1)
        
        executeSearchRequestAndParsePhotosObject(url: searchURL) { photos, error in
            guard let photos = photos, error == nil else {
                completionHandlerMainThread(nil, error)
                return
            }

            guard let availablePages = photos[jsonResponseKeys.pages] as? Int else {
                completionHandlerMainThread(nil, createAPIError())
                return
            }
            
            let randomPage = Int(arc4random_uniform(UInt32(availablePages)) + 1)

            if availablePages == 1 || randomPage == 1 {
                
            }
            
            // Do not grab page one again if it is selected
            guard availablePages > 1 else {
                parsePhotoURLsFromPhotosObject(photosObject: photos, completionHandler: completionHandlerMainThread)
                return
            }
            
            // If there is more than one page grab a random page
            let searchURLWithRandomPage = createGetImageURLsForLocationURL(coordinate: coordinate, page: randomPage)
            
            executeSearchRequestAndParsePhotosObject(url: searchURLWithRandomPage) { photos, error in
                guard let photos = photos, error == nil else {
                    completionHandlerMainThread(nil, error)
                    return
                }
                parsePhotoURLsFromPhotosObject(photosObject: photos, completionHandler: completionHandlerMainThread)
            }
        }
    }
    
    // MARK: Retrieve a picture
    
    static func getImageDataForPath(path: URL, completionHandler: @escaping (_ imageData: Data?, _ error: Error?) -> ()) {
        let completionHandlerMainThread: (_ imageData: Data?, _ error: Error?) -> () = { imageData, error in
            DispatchQueue.main.async {
                completionHandler(imageData, error)
            }
        }
        
        HTTPClient.getRequest(url: path, headerFields: nil) { data, error in
            
            guard let data = data, error == nil else {
                completionHandlerMainThread(nil, error)
                return
            }
            
            completionHandlerMainThread(data, nil)
        }
    }
    
    // MARK: Execute Search Request and parse the Photos Object
    
    static private func executeSearchRequestAndParsePhotosObject(url: URL, completionHandler: @escaping (_ parsedResult: [String: AnyObject]?, _ error: Error?) ->()) {
        HTTPClient.getRequest(url: url, headerFields: nil) { data, error in
            
            guard let data = data, error == nil else {
                completionHandler(nil, error)
                return
            }
            
            let parsedResult = HTTPClient.parseData(data: data)
            
            guard let parsedData = parsedResult.parsedData, parsedResult.error == nil else {
                completionHandler(nil, parsedResult.error)
                return
            }
            
            // Check response status field
            guard parsedData[jsonResponseKeys.status] as! String == jsonResponseValues.okStatus else {
                completionHandler(nil, createAPIError())
                return
            }
            
            guard let photos = parsedData[jsonResponseKeys.photos] as? [String : AnyObject] else {
                completionHandler(nil, createAPIError())
                return
            }
            
            completionHandler(photos, nil)
            
        }
    }
    
    // MARK: Parse the Photo URLs from the parsed Photos object
    
    static private func parsePhotoURLsFromPhotosObject(photosObject: [String: AnyObject], completionHandler: @escaping (_ photoURLs: [URL]?, _ error: Error?) -> ()) {
        var photoURLs = [URL]()
        
        guard let photoArray = photosObject[jsonResponseKeys.photo] as? [AnyObject] else {
            completionHandler(nil, createAPIError())
            return
        }
        
        // Select random photos
        let shuffledPhotoArray = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: photoArray)
        let upperBound = min(shuffledPhotoArray.count, Constants.defaults.photoAlbumSize) - 1
        
        if upperBound > 0 {
            for index in 0 ... upperBound {
                let photoObject = shuffledPhotoArray[index] as? [String: AnyObject]
                
                guard let urlMediumString = photoObject?[jsonResponseKeys.mediumURL] as? String else {
                    continue
                }
                
                guard let urlMedium = URL(string: urlMediumString) else {
                    continue
                }
                
                photoURLs.append(urlMedium)
            }
        }
        
        completionHandler(photoURLs, nil)
    }
    
    // MARK: Create search URL
    
    static private func createGetImageURLsForLocationURL(coordinate: CLLocationCoordinate2D, page: Int) -> URL {
        let bbox = createBBoxString(longitude: coordinate.longitude, latitude: coordinate.latitude)
        
        let requestHeader = [
            parameterKeys.method : parameterValues.searchMethod,
            parameterKeys.apiKey : parameterValues.apiKey,
            parameterKeys.format : parameterValues.jsonFormat,
            parameterKeys.noJSONCallback : parameterValues.disableJSONCallback,
            parameterKeys.bbox : bbox,
            parameterKeys.safeSearch : parameterValues.useSafeSearch,
            parameterKeys.contentType : parameterValues.contentTypePhotos,
            parameterKeys.geoContext : parameterValues.geoContextOutdoors,
            parameterKeys.extras : parameterValues.mediumURL,
            parameterKeys.perPage : parameterValues.defaultPerPage,
            parameterKeys.page : page
            ] as [String : Any]
        
        var components = URLComponents()
        components.scheme = urlComponents.scheme
        components.host = urlComponents.host
        components.path = urlComponents.path
        components.queryItems = [URLQueryItem]()
        
        for (name, value) in requestHeader {
            components.queryItems?.append(URLQueryItem(name: name, value: "\(value)"))
        }
        
        return components.url!
    }

    // MARK: Helper methods
    
    static private func createBBoxString(longitude: Double, latitude: Double) -> String {
        let minLongitude = max(longitude - searchBBox.halfWidth, searchBBox.lonRange.0)
        let minLatitude = max(latitude - searchBBox.halfHeight, searchBBox.latRange.0)
        let maxLongitude = min(longitude + searchBBox.halfWidth, searchBBox.lonRange.1)
        let maxLatitude = min(latitude + searchBBox.halfHeight, searchBBox.latRange.1)
        return "\(minLongitude),\(minLatitude),\(maxLongitude),\(maxLatitude)"
    }
    
    static private func createAPIError() -> Error {
        return HTTPClient.createError(domain: "FlickrClient", error: errorMessages.apiError)
    }
}
