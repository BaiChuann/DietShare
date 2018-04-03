//
//  Restaurant.swift
//  DietShare
//
//  Created by Shuang Yang on 26/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

/**
 * A Restaurant object contains the information corresponding to a restaurant in real world.
 */

class Restaurant: ReadOnlyRestaurant, Comparable {
    
    
    private let id: String
    private let name: String
    private let address: String
    private let phone: String
    private let type: RestaurantType
    private let description: String
    private let image: UIImage
    private var ratings: IDList
    private var posts: IDList
    private var ratingScore: Double
    
    init(_ id: String, _ name: String, _ address: String, _ phone: String, _ type: RestaurantType, _ description: String, _ image: UIImage, _ ratings: IDList, _ posts: IDList, _ ratingScore: Double) {
        self.id = id
        self.name = name
        self.address = address
        self.phone = phone
        self.type = type
        self.description = description
        self.image = image
        self.ratings = ratings
        self.posts = posts
        self.ratingScore = ratingScore
    }
    
    convenience init(_ id: String, _ name: String, _ address: String, _ phone: String, _ type: RestaurantType, _ description: String, _ image: UIImage) {
        self.init(id, name, address, phone, type, description, image, IDList(.Rating), IDList(.Post), 0)
    }
    
    func getID() -> String {
        return self.id
    }
    func getName() -> String {
        return self.name
    }
    func getPhone() -> String {
        return self.phone
    }
    func getAddress() -> String {
        return self.address
    }
    func getDescription() -> String {
        return self.description
    }
    func getType() -> RestaurantType {
        return self.type
    }
    func getImage() -> UIImage {
        return self.image
    }
    func getPostsID() -> IDList {
        return self.posts
    }
    func getRatingsID() -> IDList {
        return self.ratings
    }
    func getRatingScore() -> Double {
        return self.ratingScore
    }
    
    static func <(lhs: Restaurant, rhs: Restaurant) -> Bool {
        return lhs.ratingScore < rhs.ratingScore
    }
    
    static func ==(lhs: Restaurant, rhs: Restaurant) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.description == rhs.description && lhs.address == rhs.description
    }
}