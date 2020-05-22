//
//  FlickrGeoQuery.swift
//  Virtual Tourist
//
//  Created by Wolfgang Sigel on 22.05.20.
//  Copyright © 2020 Wolfgang Sigel. All rights reserved.
//

import Foundation

struct FlickrGeoQuery {
    var longitude: Double
    var latitude: Double
    var privacyFilter = 1
    var radius = 30
    var perPage = 20
    var format = "json"
    var page: Int
    var noJsonCallback = 1
    
    init(longitude: Double, latitude: Double, page: Int) {
        self.longitude = longitude
        self.latitude = latitude
        self.page = page
    }
}

extension FlickrGeoQuery {
    func getUrl() -> URL {
        let urlString =
            "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(SearchCriteria.apiKey)&privacy_filter=\(self.privacyFilter)&lat=\(self.latitude)&lon=\(self.longitude)&radius=\(self.radius)&per_page=\(self.perPage)&page=\(self.page)&format=\(self.format)&nojsoncallback=\(self.noJsonCallback)"
        print("URL: \(urlString)")
        return URL(string: urlString)!
    }
}




struct SearchCriteria {
    static var apiKey = "845611d4e2d0258c30d6960e69e8b592"
    static var privacyFilter = 1
    static var radius = 30
    static var format = "json"
    static var noJsonCallback = 1
    static var latitude = 0.0
    static var longitude = 0.0
    static var perPage = 5
    static var page = 1
    static var farmId = 0
    static var serverId = ""
    static var id = ""
    static var secret = ""
}
