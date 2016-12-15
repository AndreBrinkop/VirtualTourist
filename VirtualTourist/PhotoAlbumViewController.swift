//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by André Brinkop on 12.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource {
    
    // MARK: Properties

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var emptyCollectionLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    var pin: Pin!
    var sortedPhotos : [Photo] {
        get {
            let photos = pin!.photos?.allObjects as! [Photo]
            let sortedPhotos = photos.sorted(by: { $0.path! < $1.path! })
            return sortedPhotos
        }
    }
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initializeMapView()
    }
    
    func initializeMapView() {
        // Set annotation
        let annotation = PinAnnotation(coordinate: pin.coordinate)
        annotation.pin = pin
        mapView.addAnnotation(annotation)
        
        // Set map region
        let mapSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let mapRegion = MKCoordinateRegionMake(pin.coordinate, mapSpan)
        mapView.setRegion(mapRegion, animated: false)
    }
    
    // MARK: Collection View Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pin.photos!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photoCell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        
        // reset cell
        photoCell.imageView.image = nil
        photoCell.activityIndicator.startAnimating()

        let photo = sortedPhotos[indexPath.row]
        
        if let imageData = photo.imageData {
            let image = UIImage(data: imageData as Data)
            photoCell.imageView.image = image
            photoCell.activityIndicator.stopAnimating()
        }

        return photoCell
    }

}
