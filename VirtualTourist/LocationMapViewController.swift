//
//  ViewController.swift
//  VirtualTourist
//
//  Created by André Brinkop on 12.12.16.
//  Copyright © 2016 André Brinkop. All rights reserved.
//

import UIKit
import MapKit

let EDIT_LABEL_HEIGHT_HIDDEN: CGFloat = 0.0
let EDIT_LABEL_HEIGHT_SHOWN: CGFloat = 80.0

class LocationMapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: Properties

    @IBOutlet var editLabelHeight: NSLayoutConstraint!
    @IBOutlet var mapView: MKMapView!
    
    private var newAnnotation: MKPointAnnotation?
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        editLabelHeight.constant = EDIT_LABEL_HEIGHT_HIDDEN
        
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
            
            print(touchCoordinates)
            newAnnotation?.coordinate = touchCoordinates
        } else {
            createNewPin()
        }
        
    }
    
    // MARK: Editing

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        editLabelHeight.constant = editing ? EDIT_LABEL_HEIGHT_SHOWN : EDIT_LABEL_HEIGHT_HIDDEN
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: Create Pin
    
    func createNewPin() {
        let _ = newAnnotation
        newAnnotation = nil
        // TODO save Pin
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if isEditing {
            mapView.removeAnnotation(view.annotation!)
            // TODO Delete Pin
            return
        }
        
        let pinVC = storyboard!.instantiateViewController(withIdentifier: "PinPhotoViewController")
        // TODO Handle selected Pin
        navigationController?.pushViewController(pinVC, animated: true)
    }


}

