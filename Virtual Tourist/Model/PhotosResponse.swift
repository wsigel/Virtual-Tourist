//
//  PhotosResponse.swift
//  Virtual Tourist
//
//  Created by Wolfgang Sigel on 11.05.20.
//  Copyright © 2020 Wolfgang Sigel. All rights reserved.
//

import Foundation

struct PhotosResponse: Codable {
    let photos: Photos
    let stat: String
}

struct Photos: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [PhotoCore]
}

struct PhotoCore: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
}

