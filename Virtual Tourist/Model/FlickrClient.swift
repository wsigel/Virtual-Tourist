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
    
    struct SearchCriteria {
        static var apiKey = "845611d4e2d0258c30d6960e69e8b592"
    }
    
    struct DownloadUrl {
        var farmId: Int64
        var serverId: String
        var id: String
        var secret: String
        
        func getDownloadUrl() -> URL {
            let url = "https://farm\(self.farmId).staticflickr.com/\(self.serverId)/\(self.id)_\(self.secret)_s.jpg"
            print(url)
            return URL(string: url)!
        }
    }
    
    
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
        //print("URL \(urlString)")
        let url = urlString.getDownloadUrl()
        //print(url)
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
    
//    class func getPhotosFor(pin: Pin?, completion: @escaping(Pin?, Photo?, Error?) -> Void) {
//        guard let pin = pin else {
//            return
//        }
//        if pin.photos!.count > 0 {
//            
//            let entries = pin.photos! as! Set<Photo>
//            
//            for entry in entries {
//                SearchCriteria.farmId = Int(entry.farm)
//                SearchCriteria.serverId = entry.server!
//                let task = URLSession.shared.dataTask(with: Endpoints.getPhoto.url) { (data, reponse, error) in
//                    if error != nil {
//                        completion(nil, nil, error)
//                    }
//                    guard let data = data else {
//                        
//                        completion(pin, entry, nil)
//                        return
//                    }
//                    entry.image = data
//                    completion(pin, entry, nil)
//                }
//                task.resume()
//            }
//            
//        }
//    }
    
}
