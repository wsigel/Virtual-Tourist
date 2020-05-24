//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Wolfgang Sigel on 11.05.20.
//  Copyright © 2020 Wolfgang Sigel. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData
import UIKit

class FlickrClient {
    
//    struct SearchCriteria {
//        static var apiKey = "845611d4e2d0258c30d6960e69e8b592"
//    }
    
    
    class func searchForPhotos(geoQuery: FlickrGeoQuery?, completion: @escaping(PhotosResponse?, CLLocationCoordinate2D?, Error?) -> Void){
        
        
        guard let geoQuery = geoQuery else {
            return
        }
        
        let pinCoordinate = CLLocationCoordinate2D(latitude: geoQuery.latitude, longitude: geoQuery.longitude)
        
        let task = URLSession.shared.dataTask(with: geoQuery.getUrl()) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(PhotosResponse.self, from: data)
                DispatchQueue.main.async {
                        completion(responseObject, pinCoordinate, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, nil, error)
                }
            }
        }
        task.resume()
    }
    
    class func getImageFor(photo: Photo, completion: @escaping(Data?, Photo, Error?) -> Void){
        guard let server = photo.server, let id = photo.id, let secret = photo.secret else {
            return
        }
        let urlString = DownloadUrl(farmId: photo.farm, serverId: server, id: id, secret: secret)
        let url = urlString.getDownloadUrl()
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                DispatchQueue.main.async {
                        completion(nil, photo, error)
                }
            }
            if let data = data {
                DispatchQueue.main.async {
                        completion(data, photo, nil)
                }
            }
        }
        task.resume()
    }
}
