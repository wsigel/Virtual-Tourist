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

class TravelLocationsCollectionViewController: UICollectionViewController {
    
    var dataController: DataController?
    var selectedCoordinate: CLLocationCoordinate2D?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let coordinate = selectedCoordinate {
            FlickrClient.searchForPhotos(latitude: coordinate.latitude, longitude: coordinate.longitude, completion: handleSearchResponse(response:error:))
        }
    }
    
    func handleSearchResponse(response: PhotosResponse?, error: Error?){
        if error == nil {
            let photos = response?.photos
            let page = photos?.page
            let pages = photos?.pages
            let photo = photos?.photo
            
        } else {
            print(error)
        }
    }
    
}
