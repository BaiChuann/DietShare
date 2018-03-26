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
    private var ratings: [Int]
    private var posts: [String]
    private var ratingScore: Int {
        get{
            let sum = 0;
            for rating in ratings {
                sum += rating
            }
            return sum / ratings.count
        }
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
