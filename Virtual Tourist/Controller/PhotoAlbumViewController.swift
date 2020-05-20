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
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoAlbumCollectionView.dataSource = self
        photoAlbumCollectionView.delegate = self
        
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
    }
    
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
}

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoAlbumCell", for: indexPath) as! PhotoAlbumCell
        cell.backgroundColor = .red
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let pins = fetchedResultsController.fetchedObjects{
            return pins[0].photos?.count ?? 0
        }
        return 0
        
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

