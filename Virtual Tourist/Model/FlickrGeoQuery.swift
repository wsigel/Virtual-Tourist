//
//  FlickrGeoQuery.swift
//  Virtual Tourist
//
//  Created by Wolfgang Sigel on 22.05.20.
//  Copyright © 2020 Wolfgang Sigel. All rights reserved.
//

import Foundation

// MARK: set some basic settings for radius, amount of returned records per Page, etc.
struct FlickrGeoQuery {
    var longitude: Double
    var latitude: Double
    var privacyFilter = 1
    var radius = 30
    var perPage = 50
    var format = "json"
    var page: Int64
    var noJsonCallback = 1
    
    init(longitude: Double, latitude: Double, page: Int64) {
        self.longitude = longitude
        self.latitude = latitude
        self.page = page
    }
}

// MARK: create URL for Flickr API => flickr.photos.search
extension FlickrGeoQuery {
    func getUrl() -> URL {
        let urlString =
            "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(SearchCriteria.apiKey)&privacy_filter=\(self.privacyFilter)&lat=\(self.latitude)&lon=\(self.longitude)&radius=\(self.radius)&per_page=\(self.perPage)&page=\(self.page)&format=\(self.format)&nojsoncallback=\(self.noJsonCallback)"
        return URL(string: urlString)!
    }
}


// MARK: put your personal api key here
struct SearchCriteria {
    static var apiKey = "845611d4e2d0258c30d6960e69e8b592"
}
