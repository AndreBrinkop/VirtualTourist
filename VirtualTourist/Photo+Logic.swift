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
    
    // MARK: Initialization
    
    convenience init(url: URL, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Photo", in: context) else {
            fatalError("Unable to find Entity name!")
        }
        
        self.init(entity: entity, insertInto: context)
        
        self.path = url.absoluteString
        
        loadImage()
    }
    
    func loadImage() {
        FlickrClient.getImageDataForPath(path: URL(string: path!)!) { imageData, error in
            guard let imageData = imageData, error == nil else {
                return
            }
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.persistentContainer.performBackgroundTask() { block in
                // Copy photo to background context
                let photo = block.object(with: self.objectID) as! Photo
                
                photo.imageData = imageData as NSData
                
                do {
                    try block.save()
                } catch {
                    let nsError = error as NSError
                    appDelegate.showErrorMessage(title: "Could not save Photo!", message: nsError.localizedDescription)
                }
            }
        }
    }
    
    
}
