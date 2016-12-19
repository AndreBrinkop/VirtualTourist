//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by André Brinkop on 12.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: Properties

    @IBOutlet var editLabelHeight: NSLayoutConstraint!
    @IBOutlet var mapView: MKMapView!
    
    private var newAnnotation: PinAnnotation?
    
    let userDefaults = UserDefaults.standard
    var context: NSManagedObjectContext!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize context
        context = appDelegate.persistentContainer.viewContext
        
        loadStoredMapRegion()
        loadStoredPins()
        
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
    
    func loadStoredPins() {
        let request: NSFetchRequest<Pin> = Pin.fetchRequest()

        do {
            let pins = try context.fetch(request)
            for pin in pins {
                showPin(pin: pin)
            }
        } catch {
            appDelegate.showErrorMessage(title: "Could not fetch stored Map Pins")
        }
    }
    
    private func showPin(pin: Pin) {
        let annotationCoordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        let annotation = PinAnnotation(coordinate: annotationCoordinate)
        annotation.pin = pin

        mapView.addAnnotation(annotation)
    }
    
    // MARK: Gesture Recognizer

    @IBAction func longPressDetected(_ sender: UIGestureRecognizer) {
        guard isEditing == false else {
            return
        }
        
        let touchLocation = sender.location(in: mapView)
        let touchCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
        
        switch sender.state {
        case .began:
            createNewAnnotation(coordinate: touchCoordinate)
        case .changed:
            newAnnotation?.coordinate = touchCoordinate
        default:
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
    
    // MARK: Create Annotation
    
    func createNewAnnotation(coordinate: CLLocationCoordinate2D) {
        let annotation = PinAnnotation(coordinate: coordinate)
        newAnnotation = annotation
        mapView.addAnnotation(annotation)
    }
    
    // MARK: Create Pin
    
    func createNewPin() {
        let pin: Pin = Pin(coordinate: newAnnotation!.coordinate, context: context)
        newAnnotation?.pin = pin
    }
    
    // MARK: Delete Pin
    
    func deletePin(pin: Pin) {
        context.delete(pin)
        appDelegate.saveContext()
    }
    
    // MARK: Map View Delegate
    
    func mapView(_ mapView: MKMapView, didSelect annotationView: MKAnnotationView) {
        guard let annotation = annotationView.annotation as? PinAnnotation else {
            return
        }
        
        mapView.deselectAnnotation(annotation, animated: true)

        guard let pin = annotation.pin else {
            return
        }
        
        if isEditing {
            // Delete Pin
            
            // animate rise
            UIView.animate(withDuration: 0.4, animations: {
                annotationView.frame.origin.y = annotationView.frame.origin.y - self.view.frame.size.height
            }, completion: { success in
                mapView.removeAnnotation(annotation)
            })

            deletePin(pin: pin)
            return
        }
        
        // Show Photo Album
        let pinVC = storyboard!.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        pinVC.pin = pin
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

