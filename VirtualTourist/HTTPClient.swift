//
//  HTTPClient.swift
//  OnTheMap
//
//  Created by André Brinkop on 01.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import UIKit
import Foundation

class HTTPClient {
    
    // MARK: Properties
    
    static let session = URLSession.shared
    
    // MARK: Convenience Methods
    
    static func getRequest(url: URL, headerFields: [String : String]?, completionHandler: @escaping (_ result: Data?, _ error: Error?) -> Void) {
        httpRequest(url: url, httpMethod: "GET", headerFields: headerFields, httpBody: nil, completionHandler: completionHandler)
    }
    
    static func postRequest(url: URL, headerFields: [String : String]?, httpBody: [String : AnyObject]?, completionHandler: @escaping (_ result: Data?, _ error: Error?) -> Void) {
        httpRequest(url: url, httpMethod: "POST", headerFields: headerFields, httpBody: httpBody, completionHandler: completionHandler)
    }
    
    static func putRequest(url: URL, headerFields: [String : String]?, httpBody: [String : AnyObject]?, completionHandler: @escaping (_ result: Data?, _ error: Error?) -> Void) {
        httpRequest(url: url, httpMethod: "PUT", headerFields: headerFields, httpBody: httpBody, completionHandler: completionHandler)
    }
    
    static func deleteRequest(url: URL, headerFields: [String : String]?, completionHandler: @escaping (_ result: Data?, _ error: Error?) -> Void) {
        httpRequest(url: url, httpMethod: "DELETE", headerFields: headerFields, httpBody: nil, completionHandler: completionHandler)
    }
    
    // MARK: Request Method
    
    static func httpRequest(url: URL, httpMethod: String, headerFields: [String : String]?,  httpBody: [String : AnyObject]?, completionHandler: @escaping (_ result: Data?, _ error: Error?) -> Void) {
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        
        if let headerFields = headerFields {
            for headerField in headerFields {
                request.addValue(headerField.value, forHTTPHeaderField: headerField.key)
            }
        }
        
        if let httpBody = httpBody {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: httpBody)
            } catch {
                completionHandler(nil, createError(domain: "parseJSON", error: "Can not parse JSON body"))
                return
            }
        }
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            networkActivityIndicator(isVisible: false)
            
            if let responseError = checkForError(data: data, response: response, error: error) {
                completionHandler(nil, responseError)
                return
            }
            
            completionHandler(data, nil)
        }
        task.resume()
        networkActivityIndicator(isVisible: true)
    }
    
    // MARK: Parse data
    
    static func parseData(data: Data?) -> (parsedData: [String: AnyObject]?, error: Error?) {
        guard let data = data else {
            return (parsedData: nil, error: createError(domain: "parseData", error: "No data to parse"))
        }
        
        do {
            let parsedData = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
            return (parsedData: parsedData, error: nil)
        } catch {
            return (parsedData: nil, error: createError(domain: "parseData", error: "Could not parse the data as JSON: '\(data)'"))
        }
    }
    
    // MARK: Check for Errors
    
    static private func checkForError(data: Data?, response: URLResponse?, error: Error?) -> Error? {
        /* GUARD: Was there an error? */
        guard (error == nil) else {
            return error
        }
        
        /* GUARD: Did we get a successful 2XX response? */
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
            return createError(domain: "httpResponseCode", error: "Your request returned a status code other than 2xx!")
        }
        
        /* GUARD: Was there any data returned? */
        guard data != nil else {
            return createError(domain: "httpResponseData", error: "No data was returned by the request!")
        }
        
        return nil
    }
    
    // MARK: Helper Methods
    
    static func createError(domain: String, error: String) -> NSError {
        let userInfo = [NSLocalizedDescriptionKey: error]
        return NSError(domain: domain, code: 1, userInfo: userInfo)
    }
    
    // Substitute the Key for the Value within the Method Name
    static func substituteKeyInMethod(_ method: String, key: String, value: String) -> String? {
        if method.range(of: "<\(key)>") != nil {
            return method.replacingOccurrences(of: "<\(key)>", with: value)
        } else {
            return nil
        }
    }
    
    // MARK: Network Activity Indicator
    
    private static var activityCounter: Int = 0
    
    static func networkActivityIndicator(isVisible: Bool) {
        activityCounter += isVisible ? 1 : -1
        
        if activityCounter < 1 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        } else {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
    }
    
}
