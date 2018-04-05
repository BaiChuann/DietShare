//
//  Restaurant.swift
//  DietShare
//
//  Created by Shuang Yang on 26/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

/**
 * A Restaurant object contains the information corresponding to a restaurant in real world.
 */

class Restaurant: ReadOnlyRestaurant {
    
    
    private let id: String
    private let name: String
    private let address: String
    private let location: CLLocation
    private let phone: String
    // TODO - change type to List (of type)
    private let types: StringList
    private let description: String
    private let image: UIImage
    private var ratings: StringList
    private var posts: StringList
    private var ratingScore: Double
    
    init(_ id: String, _ name: String, _ address: String, _ location: CLLocation, _ phone: String, _ types: StringList, _ description: String, _ image: UIImage, _ ratings: StringList, _ posts: StringList, _ ratingScore: Double) {
        self.id = id
        self.name = name
        self.address = address
        self.location = location
        self.phone = phone
        self.types = types
        self.description = description
        self.image = image
        self.ratings = ratings
        self.posts = posts
        self.ratingScore = ratingScore
    }
    
    convenience init(_ id: String, _ name: String, _ address: String, _ location: CLLocation, _ phone: String, _ types: StringList, _ description: String, _ image: UIImage) {
        self.init(id, name, address, location, phone, types, description, image, StringList(.Rating), StringList(.Post), 0)
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
    func getLocation() -> CLLocation {
        return self.location
    }
    func getDescription() -> String {
        return self.description
    }
    func getTypes() -> StringList {
        return self.types
    }
    func getImage() -> UIImage {
        return self.image
    }
    func getPostsID() -> StringList {
        return self.posts
    }
    func getRatingsID() -> StringList {
        return self.ratings
    }
    func getRatingScore() -> Double {
        return self.ratingScore
    }
    func addRating(_ rating: Rating) {
        let score = rating.getScore()
        self.ratingScore = calcNewRatingScore(score)
        self.ratings.addEntry(rating.getID())
    }
    func addPost(_ post: Post) {
        self.posts.addEntry(post.getPostId())
    }
    
    private func calcNewRatingScore(_ newScore: Double) -> Double {
        let numOfRating = Double(self.ratings.getListAsSet().count)
        let newAvg = (self.ratingScore * numOfRating + newScore) / (numOfRating + 1)
        return newAvg
    }
    
    func getDistanceToCurrent() -> Double {
        // TODO - implement core location here
        let currentLocation = CLLocation(latitude: 0.0, longitude: 103.0)
        let distance = currentLocation.distance(from: self.location)
        return Double(round(distance * 10) / 10)
    }
    
}

extension Restaurant {
    static func <(lhs: Restaurant, rhs: Restaurant) -> Bool {
        return lhs.ratingScore > rhs.ratingScore
    }
    
    static func ==(lhs: Restaurant, rhs: Restaurant) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name && lhs.description == rhs.description && lhs.address == rhs.description
    }
}
