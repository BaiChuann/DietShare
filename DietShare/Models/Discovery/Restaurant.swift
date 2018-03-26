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

class Restaurant: ReadOnlyRestaurant {
    private let id: String
    private let name: String
    private let address: String
    private let phone: String
    private let type: RestaurantType
    private let description: String
    private let profilePhoto: UIImage
    private var ratings: [Double]
    private var posts: [String]
    private var ratingScore: Double {
        get{
            var sum = 0.0;
            for rating in ratings {
                sum += rating
            }
            return sum / Double(ratings.count)
        }
    }
    
    init(_ id: String, _ name: String, _ address: String, _ phone: String, _ type: RestaurantType, _ description: String, profilePhoto: UIImage) {
        self.id = id
        self.name = name
        self.address = address
        self.phone = phone
        self.type = type
        self.description = description
        self.profilePhoto = profilePhoto
        self.ratings = [Double]()
        self.posts = [String]()
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
    func getProfilePhoto() -> UIImage {
        return self.profilePhoto
    }
    func getPostsID() -> [String] {
        return self.posts
    }
    func getRatingScore() -> Double {
        return self.ratingScore
    }
}
