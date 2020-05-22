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

class PhotoAlbumViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    @IBOutlet weak var photoAlbumCollectionView: UICollectionView!
    
    var selectedCoordinate: CLLocationCoordinate2D!
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setUpFetchedResultsController()
    
        photoAlbumCollectionView.dataSource = self
        photoAlbumCollectionView.delegate = self
        
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
        guard let imageData = imageData else {
            return
        }
        
        do {
            photo.image = imageData
            try dataController.viewContext.save()
        } catch {
            fatalError("Image could not be saved \(error.localizedDescription)")
        }
        
        //print("secret \(photo.secret)")
    }
    
    fileprivate func setUpFetchedResultsController() {
        let pin = getPinFor(coordinate: self.selectedCoordinate)
        //print("ObjectId in Collection: \(pin.objectID)")
        let pinPredicate = NSPredicate(format: "pin = %@", pin)
        let photoSortDescriptor = NSSortDescriptor(key: "secret", ascending: true)
        let photosFetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        photosFetchRequest.sortDescriptors = [photoSortDescriptor]
        photosFetchRequest.predicate = pinPredicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: photosFetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        
        fetchedResultsController.delegate = self
        
        
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
}

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCell", for: indexPath) as! PhotoAlbumCell
        let photo = fetchedResultsController.object(at: indexPath)
        print("Photodetails \(photo.farm)_\(photo.server)_\(photo.id)_\(photo.secret)")
        if let imageData = photo.image {
            cell.photoAlbumImageView.image = UIImage(data: imageData)
        }
        
        cell.backgroundColor = .red
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    //    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    //        //let aPhoto = fetchedResultsController.object(at: indexPath)
    //        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCollectionViewCell", for: indexPath) as! PhotoAlbumCollectionViewCell
    //        //cell.photoImageView.image = UIImage(named: <#T##String#>)
    //        cell.backgroundColor = .red
    //        return cell
    //    }
    
    
    
    
    
    //    func numberOfSections(in collectionView: UICollectionView) -> Int {
    //        return fetchedResultsController.sections?.count ?? 1
    //    }
    
}

