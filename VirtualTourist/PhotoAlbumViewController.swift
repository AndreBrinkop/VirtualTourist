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

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate {
    
    // MARK: Properties

    @IBOutlet var mapView: MKMapView!
    @IBOutlet var loadingPhotosActivityIndicator: UIActivityIndicatorView!
    @IBOutlet var emptyAlbumLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet var photoAlbumToolbarButton: UIBarButtonItem!
    
    var pin: Pin!

    var fetchedResultsController: NSFetchedResultsController<Photo>!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var allPhotosLoaded = false
    
    let newCollectionString = "New Collection"
    let removeSelectedPhotosString = "Remove Selected Photos"

    
    // MARK: Initialization
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFetchedResultsController()
        initializeMapView()
        initializeCollectionView()
        configurePhotoAlbum()
    }
    
    func initializeFetchedResultsController() {
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
    
    func initializeCollectionView() {
        collectionView.allowsMultipleSelection = true

        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        
        if let collectionViewFlowLayout = collectionViewFlowLayout {
            collectionViewFlowLayout.minimumInteritemSpacing = space
            collectionViewFlowLayout.minimumLineSpacing = space
            collectionViewFlowLayout.itemSize = CGSize(width: dimension, height: dimension)
        }
    }
    
    // MARK: Configure UI
    
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
        if !collectionView.indexPathsForSelectedItems!.isEmpty {
            photoAlbumToolbarButton.isEnabled = true
            photoAlbumToolbarButton.title = removeSelectedPhotosString
            return
        }
        
        photoAlbumToolbarButton.title = newCollectionString
        if areAllPhotosLoaded() {
            photoAlbumToolbarButton.isEnabled = true
            return
        }
        photoAlbumToolbarButton.isEnabled = false
    }
    
    // MARK: Collection View Delegate
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let selectedPhoto = fetchedResultsController.object(at: indexPath)
        let selectedCell = collectionView.cellForItem(at: indexPath)!

        guard selectedCell.isSelected == false else {
            collectionView.deselectItem(at: indexPath, animated: false)
            return false
        }
        
        guard selectedPhoto.errorWhileLoading == false else {
            selectedPhoto.loadImage()
            return false
        }
        
        guard selectedPhoto.isLoading == false else {
            return false
        }
        
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        configureToolBarButton()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        configureToolBarButton()
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
            guard selectedPhoto.errorWhileLoading == false else {
                // error while loading
                cell.errorLabel.isHidden = false
                cell.activityIndicator.stopAnimating()
                return
            }
            
            guard selectedPhoto.isLoading == false else {
                // loading image
                cell.imageView.image = nil
                cell.errorLabel.isHidden = true
                cell.activityIndicator.startAnimating()
                return
            }
            
            // loaded image
            let image = UIImage(data: selectedPhoto.imageData! as Data)
            cell.imageView.image = image
            cell.activityIndicator.stopAnimating()
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
            op = BlockOperation { self.collectionView.deleteItems(at: [indexPath!]) }
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
    
    // MARK: Toolbar Button Action
    
    @IBAction func pressedToolbarButton(_ sender: UIBarButtonItem) {
        let context = appDelegate.persistentContainer.viewContext

        if sender.title == newCollectionString {
            pin.loadNewPhotos(context: context)
        }
        
        if sender.title == removeSelectedPhotosString {
            let selectedPhotos: [Photo] = collectionView.indexPathsForSelectedItems!.map() { fetchedResultsController.object(at: $0)}
            
            context.perform() {
                let _ = selectedPhotos.map() { context.delete($0) }
                self.appDelegate.saveContext()
            }
            
        }
        
        configureToolBarButton()
    }
    
    // MARK: Helper
    
    func areAllPhotosLoaded() -> Bool {
        guard let results = fetchedResultsController.fetchedObjects, pin.loadedPhotos else {
            return false
        }
        
        for photo in results {
            if photo.imageData == nil {
                return false
            }
        }
        
        return true
    }

}
