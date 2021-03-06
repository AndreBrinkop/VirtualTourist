//
//  Photo+Logic.swift
//  VirtualTourist
//
//  Created by André Brinkop on 13.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation
import MapKit
import CoreData

extension Photo {
    
    // MARK: Properties
    
    var isLoading : Bool {
        get {
            return imageData == nil && downloadingImageData
        }
    }
    
    var errorWhileLoading : Bool {
        get {
            return imageData == nil && !downloadingImageData
        }
    }
    
    // MARK: Initialization
    
    convenience init(pin: Pin, url: URL, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context) else {
            fatalError("Unable to find Entity name!")
        }
        
        self.init(entity: entity, insertInto: context)
        
        self.pin = pin
        path = url.absoluteString
        downloadingImageData = true
    }
    
    func loadImage() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.persistentContainer.performBackgroundTask() { block in
            
            // Copy photo to background context
            let photo = block.object(with: self.objectID) as! Photo
            
            photo.downloadingImageData = true
            appDelegate.saveContext(block)

            FlickrClient.getImageDataForPath(path: URL(string: photo.path!)!) { imageData, error in
                block.perform {
                    block.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                    
                    if let imageData = imageData, error == nil {
                        photo.imageData = imageData as NSData
                    }
                    
                    photo.downloadingImageData = false
                    appDelegate.saveContext(block)
                }
            }
        }
    }
    
    
}
