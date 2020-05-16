//
//  TravelLocationsCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Wolfgang Sigel on 12.05.20.
//  Copyright © 2020 Wolfgang Sigel. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import CoreData

class PhotoAlbumViewController: UIViewController, NSFetchedResultsControllerDelegate {
    
    var dataController: DataController!
    var selectedCoordinate: CLLocationCoordinate2D?
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    
    fileprivate func setUpFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let latPredicate = NSPredicate(format: "latitude == \(selectedCoordinate!.latitude)")
        let longPredicate = NSPredicate(format: "longitude == \(selectedCoordinate!.longitude)")
        let coordinatesPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [latPredicate, longPredicate])
    
        fetchRequest.predicate = coordinatesPredicate
        fetchRequest.includesSubentities = true
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
            guard let coordinate = self.selectedCoordinate else {
                return
            }
        setUpFetchedResultsController()
        if let pin = fetchedResultsController.fetchedObjects?.first {
            let photos = pin.photos as! Set<Photo>
            for photo in photos {
                if photo.image == nil {
                    
                }
            }
        }
        
        
        
//        if let coordinate = selectedCoordinate {
//            FlickrClient.searchForPhotos(latitude: coordinate.latitude, longitude: coordinate.longitude, completion: handleSearchResponse(response:error:))
//        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    
    
}
