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

class PhotoAlbumViewController: UIViewController, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    // MARK: Properties

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var loadingPhotosActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var emptyAlbumLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var photoAlbumToolbarButton: UIBarButtonItem!
    
    var pin: Pin!

    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    func initializeFetchedResultsController() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let request: NSFetchRequest<Photo> = Photo.fetchRequest()
        
        let predicate = NSPredicate(format: "pin = %@", pin)
        let sortDescriptor = NSSortDescriptor(key: "path", ascending: true)
        
        request.predicate = predicate
        
        request.sortDescriptors = [sortDescriptor]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: appDelegate.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            appDelegate.showErrorMessage(title: "Failed to fetch stored Photos!", message: error.localizedDescription)
        }
    }
    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFetchedResultsController()
        initializeMapView()
        configurePhotoAlbum()
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
    
    func configurePhotoAlbum(){
        let loadedPhotoCount = collectionView(collectionView, numberOfItemsInSection: 0)
        
        guard loadedPhotoCount > 0 else {
            if pin.loadedPhotos {
                // did not find photos
                emptyAlbumLabel.text = "No Photos Found!"
                loadingPhotosActivityIndicator.stopAnimating()
            } else {
                // is loading photos
                emptyAlbumLabel.text = "Loading Photos.."
                loadingPhotosActivityIndicator.startAnimating()
            }
            
            emptyAlbumLabel.isHidden = false
            configureToolBarButton()
            return
        }
        
        // found photos
        emptyAlbumLabel.isHidden = true
        loadingPhotosActivityIndicator.stopAnimating()
        configureToolBarButton()
    }
    
    func configureToolBarButton() {
        if pin.loadedPhotos {
            photoAlbumToolbarButton.isEnabled = true
            return
        }
        photoAlbumToolbarButton.isEnabled = false
    }
    
    // MARK: Collection View Data Source
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sections = fetchedResultsController.sections!
        let sectionInfo = sections[section]
        return sectionInfo.numberOfObjects
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath)
        // Set up the cell
        configureCell(cell: cell, indexPath: indexPath)
        
        return cell
    }
    
    // MARK: Configure PhotoCollectionViewCells
    
    func configureCell(cell: UICollectionViewCell?, indexPath: IndexPath) {
        guard let cell = cell as? PhotoCollectionViewCell else {
            return
        }
        
        let selectedPhoto = fetchedResultsController.object(at: indexPath)
        
        DispatchQueue.main.async {
            // reset cell
            cell.imageView.image = nil
            cell.activityIndicator.startAnimating()
            
            if let imageData = selectedPhoto.imageData {
                let image = UIImage(data: imageData as Data)
                cell.imageView.image = image
                cell.activityIndicator.stopAnimating()
            }
        }
    }
    
    // MARK: Fetched Results Controller Delegate
    
    private var blockOperations: [BlockOperation] = []
    
    func controllerWillChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        var op = BlockOperation {}
        
        switch type {
        case .insert:
            op = BlockOperation { self.collectionView.insertItems(at: [newIndexPath!]) }
        case .delete:
            op = BlockOperation { self.collectionView.deleteItems(at: [newIndexPath!]) }
            blockOperations.append(op)
        case .update:
            op = BlockOperation { self.configureCell(cell: self.collectionView.cellForItem(at: indexPath!), indexPath: indexPath!) }
        case .move:
            op = BlockOperation { self.collectionView.moveItem(at: indexPath!, to: newIndexPath!) }
        }
        
        blockOperations.append(op)
    }
    
    func controllerDidChangeContent(_: NSFetchedResultsController<NSFetchRequestResult>) {
        
        DispatchQueue.main.async {
            self.configurePhotoAlbum()
        }
        
        collectionView.performBatchUpdates({
            self.blockOperations.forEach { $0.start() }
        }, completion: { finished in
            self.blockOperations.removeAll(keepingCapacity: false)
        })
    }

}
