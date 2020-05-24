//
//  DownloadUrl.swift
//  Virtual Tourist
//
//  Created by Wolfgang Sigel on 24.05.20.
//  Copyright © 2020 Wolfgang Sigel. All rights reserved.
//

import Foundation

struct DownloadUrl {
    var farmId: Int64
    var serverId: String
    var id: String
    var secret: String
    
    
}

// MARK: create Flickr photo source URL for downloading
extension DownloadUrl {
    func getDownloadUrl() -> URL {
        let url = "https://farm\(self.farmId).staticflickr.com/\(self.serverId)/\(self.id)_\(self.secret)_s.jpg"
        return URL(string: url)!
    }
}
