//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Wolfgang Sigel on 11.05.20.
//  Copyright © 2020 Wolfgang Sigel. All rights reserved.
//

import Foundation
import CoreLocation

class FlickrClient {
    
    struct SearchCriteria {
        static var apiKey = "845611d4e2d0258c30d6960e69e8b592"
        static var privacyFilter = 1
        static var radius = 30
        static var format = "json"
        static var noJsonCallback = 1
        static var latitude = 0.0
        static var longitude = 0.0
        static var perPage = 20
        static var page = 1
        static var farmId = 0
        static var serverId = ""
        static var id = ""
        static var secret = ""
    }
    
    enum Endpoints {
        static let baseSearch = "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(SearchCriteria.apiKey)&privacy_filter=\(SearchCriteria.privacyFilter)&lat=\(SearchCriteria.latitude)&lon=\(SearchCriteria.longitude)&radius=\(SearchCriteria.radius)&per_page=\(SearchCriteria.perPage)&page=\(SearchCriteria.page)&format=\(SearchCriteria.format)&nojsoncallback=\(SearchCriteria.noJsonCallback)"
        
        static let basePhoto = "https://farm\(SearchCriteria.farmId).staticflickr.com/\(SearchCriteria.serverId)/\(SearchCriteria.id)_\(SearchCriteria.secret)_s.jpg"
        
        case searchForPhotos
        case getPhoto
        
        var stringValue: String {
            switch self {
            case .searchForPhotos: return Endpoints.baseSearch
            case .getPhoto: return Endpoints.basePhoto
            }
        }
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func searchForPhotos(latitude: Double?, longitude: Double?, completion: @escaping(PhotosResponse?, Error?) -> Void){
        
        guard let latitude = latitude, let longitude = longitude else {
            return
        }
        SearchCriteria.latitude = latitude
        SearchCriteria.longitude = longitude
        let task = URLSession.shared.dataTask(with: Endpoints.searchForPhotos.url) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(PhotosResponse.self, from: data)
                DispatchQueue.main.async {
                        completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
    }
    
    class func getPhoto() {
        
    }
}