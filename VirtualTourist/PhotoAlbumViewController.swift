//
//  PinPhotoViewController.swift
//  VirtualTourist
//
//  Created by André Brinkop on 12.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {
    
    // MARK: Properties

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var emptyCollectionLabel: UILabel!
    
    var pin: Pin!
    
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
        
        let mapSpan = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let mapRegion = MKCoordinateRegionMake(pin.coordinate, mapSpan)
        mapView.setRegion(mapRegion, animated: false)
        

    }

}
