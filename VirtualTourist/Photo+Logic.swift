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
    
    convenience init(url: URL, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context) else {
            fatalError("Unable to find Entity name!")
        }
        
        self.init(entity: entity, insertInto: context)
        
        path = url.absoluteString
        downloadingImageData = false

    }
    
    func loadImage(context: NSManagedObjectContext) {
        downloadingImageData = true
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.saveContext(context)

        FlickrClient.getImageDataForPath(path: URL(string: path!)!) { imageData, error in
            appDelegate.persistentContainer.performBackgroundTask() { block in
                block.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
                // Copy photo to background context
                let photo = block.object(with: self.objectID) as! Photo
                
                if let imageData = imageData, error == nil {
                    photo.imageData = imageData as NSData
                }
                
                photo.downloadingImageData = false
                appDelegate.saveContext(block)
            }
        }
    }
    
    
}
