//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by Wolfgang Sigel on 20.05.20.
//  Copyright © 2020 Wolfgang Sigel. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreData

class PhotoAlbumViewController: UIViewController {
    
    @IBOutlet weak var photoAlbumCollectionView: UICollectionView!
    
    var selectedCoordinate: CLLocationCoordinate2D!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    var currentPin: Pin!
    
    @IBAction func newAlbumTapped(_ sender: Any) {
        let newPage = currentPin.page < currentPin.pages ? currentPin.page + 1 : 1
        
        if newPage != currentPin.page {
            if let photos = fetchedResultsController.fetchedObjects {
                for photo in photos {
                    currentPin.removeFromPhotos(photo)
                }
            }
            let flickrGeoQuery = FlickrGeoQuery(longitude: currentPin.longitude, latitude: currentPin.latitude, page: newPage)
            
            FlickrClient.searchForPhotos(geoQuery: flickrGeoQuery, completion: handleNewAlbumResponse(response:_:error:))
            
            currentPin.page = newPage
        }
    }
    
    
    
    func handleNewAlbumResponse(response: PhotosResponse?, _ coordinate: CLLocationCoordinate2D?, error: Error? ){
        if error == nil {
            guard let response = response else {
                return
            }
            let photoCore = response.photos.photo
            if photoCore.count > 0 {
                for individualPhoto in photoCore {
                    let photo = Photo(context: dataController.viewContext)
                    photo.id = individualPhoto.id
                    photo.secret = individualPhoto.secret
                    photo.farm = Int64(individualPhoto.farm)
                    photo.server = individualPhoto.server
                    currentPin.addToPhotos(photo)
                }
                do {
                    try dataController.viewContext.save()
                } catch {
                    fatalError("Unable to save context \(error.localizedDescription)")
                }
                photoAlbumCollectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setUpFetchedResultsController()
    
        photoAlbumCollectionView.dataSource = self
        photoAlbumCollectionView.delegate = self
        fetchedResultsController.delegate = self
        
        guard let coordinate = self.selectedCoordinate else {
            return
        }
        
        if let photos = fetchedResultsController.fetchedObjects {
            
            for photo in photos {
                if photo.image == nil {
                    guard let serverId = photo.server, let id = photo.id, let secret = photo.secret else {
                        return
                    }

                    FlickrClient.getImageFor(photo: photo, completion: handleImageResponse(imageData:photo:error:))
                }
                
            }
            
        }
    }
    

    
    func handleImageResponse(imageData: Data?, photo: Photo, error: Error?){
        let backgroundContext: NSManagedObjectContext! = dataController.backgroundContext
        guard let imageData = imageData else {
            return
        }
        let photoId = photo.objectID
        do {
            let backgroundPhoto = backgroundContext.object(with: photoId) as! Photo
            backgroundPhoto.image = imageData
            try dataController.backgroundContext.save()
        } catch {
            fatalError("Image could not be saved \(error.localizedDescription)")
        }
    }
    
    fileprivate func setUpFetchedResultsController() {
        currentPin = getPinFor(coordinate: self.selectedCoordinate)
        let pinPredicate = NSPredicate(format: "pin = %@", currentPin)
        let photoSortDescriptor = NSSortDescriptor(key: "secret", ascending: true)
        let photosFetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        photosFetchRequest.sortDescriptors = [photoSortDescriptor]
        photosFetchRequest.predicate = pinPredicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: photosFetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        
        //fetchedResultsController.delegate = self
        
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    func getPinFor(coordinate: CLLocationCoordinate2D) -> Pin {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptorLat = NSSortDescriptor(key: "latitude", ascending: true)
        let sortDescriptorLong = NSSortDescriptor(key: "longitude", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptorLat, sortDescriptorLong]
        let latPredicate = NSPredicate(format: "latitude == \(selectedCoordinate!.latitude)")
        let longPredicate = NSPredicate(format: "longitude == \(selectedCoordinate!.longitude)")
        let coordinatesPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [latPredicate, longPredicate])
        
        fetchRequest.predicate = coordinatesPredicate
        fetchRequest.includesSubentities = true
        do {
             let pin = try dataController.viewContext.fetch(fetchRequest)
            return pin.first!
        } catch {
            fatalError("Could not retrieve Pin for coordinates \(error.localizedDescription)")
        }
    }
    
    func deletePhoto(indexPath: IndexPath){
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(photoToDelete)
        do {
            try dataController.viewContext.save()
        } catch  {
            fatalError("Could not delete photo from collection \(error.localizedDescription)")
        }
        
    }
}

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let backgroundContext: NSManagedObjectContext! = dataController.backgroundContext
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCell", for: indexPath) as! PhotoAlbumCell
        let photo = fetchedResultsController.object(at: indexPath)
        print("Photodetails \(photo.farm)_\(photo.server)_\(photo.id)_\(photo.secret)")
        if let imageData = photo.image {
            cell.photoAlbumImageView.image = UIImage(data: imageData)
        } else {
            // download the image on background thread
            let photoId = photo.objectID
            
            backgroundContext.perform {
                let backgroundPhoto = backgroundContext.object(with: photoId) as! Photo
                FlickrClient.getImageFor(photo: backgroundPhoto, completion: self.handleImageResponse(imageData:photo:error:))
            }
        }
        
        cell.backgroundColor = .red
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        deletePhoto(indexPath: indexPath)
        photoAlbumCollectionView.deleteItems(at: [indexPath])
    }
    
    
    
    
    
    
    
    //    func numberOfSections(in collectionView: UICollectionView) -> Int {
    //        return fetchedResultsController.sections?.count ?? 1
    //    }
    
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .update:
            photoAlbumCollectionView.reloadItems(at: [indexPath!])
            break
        case .delete:
            break
        case .insert:
            break
        case .move:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
}

