//
//  Pin+Logic.swift
//  VirtualTourist
//
//  Created by André Brinkop on 13.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import Foundation
import MapKit
import CoreData

extension Pin {
    
    // MARK: Properties
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    
    var appDelegate: AppDelegate {
        get {
            return UIApplication.shared.delegate as! AppDelegate
        }
    }

    // MARK: Initialization
    
    convenience init(coordinate: CLLocationCoordinate2D, context: NSManagedObjectContext) {
        guard let entity = NSEntityDescription.entity(forEntityName: "Pin", in: context) else {
            fatalError("Unable to find Entity name!")
        }
        
        self.init(entity: entity, insertInto: context)
        
        latitude = coordinate.latitude
        longitude = coordinate.longitude
        loadedPhotos = false
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.saveContext(context)
        
        loadNewPhotos(context: context)
    }

    public func loadNewPhotos(context: NSManagedObjectContext) {
        // Just load new photos if photo album is empty
        if photos!.count > 0 {
            deleteAllPhotos(context: context)
        }
        loadedPhotos = false
        
        FlickrClient.getImageURLsForLocation(coordinate: coordinate) { urls, error in
            self.appDelegate.persistentContainer.performBackgroundTask() { block in
                func saveBlock() {
                    do {
                        try block.save()
                    } catch {
                        let nsError = error as NSError
                        self.appDelegate.showErrorMessage(title: "Could not save Pin!", message: nsError.localizedDescription)
                    }
                }
                
                guard let urls = urls, error == nil else {
                    self.loadedPhotos = true
                    saveBlock()
                    self.appDelegate.showErrorMessage(title: "Could not fetch Photos for new Pin!", message: error!.localizedDescription)
                    return
                }
                
                block.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
                
                // Copy pin to background context
                let pin = block.object(with: self.objectID) as! Pin
                
                // Initialize photos
                for url in urls {
                    let photo = Photo(url: url, context: block)
                    photo.pin = pin
                }
                
                // Load photos
                for photo in pin.photos!.allObjects {
                    (photo as! Photo).loadImage(context: block)
                }
                
                self.loadedPhotos = true
                saveBlock()
            }
        }
    }
    
    public func deleteAllPhotos(context: NSManagedObjectContext) {
        let _ = photos?.allObjects.map() { context.delete($0 as! NSManagedObject) }
        appDelegate.saveContext(context)
    }

}
