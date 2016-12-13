//
//  ViewController.swift
//  VirtualTourist
//
//  Created by André Brinkop on 12.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: Properties

    @IBOutlet var editLabelHeight: NSLayoutConstraint!
    @IBOutlet var mapView: MKMapView!
    
    private var newAnnotation: MKPointAnnotation?
    
    let userDefaults = UserDefaults.standard
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadStoredMapRegion()
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        editLabelHeight.constant = Constants.userInterface.editLabelHeightHidden
        
    }
    
    func loadStoredMapRegion() {
        
        func loadRegionParam(_ key: String) -> CLLocationDegrees? {
            return userDefaults.object(forKey: key) as? CLLocationDegrees
        }
        
        if let mapLatitude = loadRegionParam(Constants.userDefaults.mapLatitude),
            let mapLongitude = loadRegionParam(Constants.userDefaults.mapLongitude),
            let mapLatitudeDelta = loadRegionParam(Constants.userDefaults.mapLatitudeDelta),
            let mapLongitudeDelta = loadRegionParam(Constants.userDefaults.mapLongitudeDelta) {
            
            mapView.region.center = CLLocationCoordinate2D(latitude: mapLatitude, longitude: mapLongitude)
            mapView.region.span = MKCoordinateSpanMake(mapLatitudeDelta, mapLongitudeDelta)
        }
    }
    
    // MARK: Gesture Recognizer

    @IBAction func longPressDetected(_ sender: UIGestureRecognizer) {
        
        guard isEditing == false else {
            return
        }
        
        let touchLocation = sender.location(in: mapView)
        let touchCoordinates = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        
        if sender.state == .began {
            
            let annotation = MKPointAnnotation()
            let centerCoordinate = touchCoordinates
            annotation.coordinate = centerCoordinate
            newAnnotation = annotation
            
            mapView.addAnnotation(annotation)
        } else if sender.state == .changed {
            newAnnotation?.coordinate = touchCoordinates
        } else {
            createNewPin()
        }
        
    }
    
    // MARK: Editing

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        editLabelHeight.constant = editing ? Constants.userInterface.editLabelHeightShown : Constants.userInterface.editLabelHeightHidden
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: Create Pin
    
    func createNewPin() {
        let _ = newAnnotation
        // TODO save Pin
    }
    
    // MARK: Map View Delegate
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if isEditing {
            mapView.removeAnnotation(view.annotation!)
            // TODO Delete Pin
            return
        }
        
        let pinVC = storyboard!.instantiateViewController(withIdentifier: "PhotoAlbumViewController")
        // TODO Handle selected Pin
        navigationController?.pushViewController(pinVC, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        for annotationView in views {
            guard let annotation = annotationView.annotation else {
                continue
            }
            
            // find new annotation
            if annotation.isEqual(newAnnotation as? MKAnnotation) {
                
                // hide annotation
                annotationView.frame.origin.y = annotationView.frame.origin.y - self.view.frame.size.height
                
                // animate drop
                UIView.animate(withDuration: 0.4, animations: {
                    annotationView.frame.origin.y = annotationView.frame.origin.y + self.view.frame.size.height
                }, completion: nil)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        userDefaults.set(mapView.region.center.latitude, forKey: Constants.userDefaults.mapLatitude)
        userDefaults.set(mapView.region.center.longitude, forKey: Constants.userDefaults.mapLongitude)
        userDefaults.set(mapView.region.span.latitudeDelta, forKey: Constants.userDefaults.mapLatitudeDelta)
        userDefaults.set(mapView.region.span.longitudeDelta, forKey: Constants.userDefaults.mapLongitudeDelta)
    }


}

