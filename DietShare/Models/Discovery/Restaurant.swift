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
    // TODO - Add Opening hours
    private var types: StringList
    private let description: String
    private let imagePath: String
    private var ratings: RatingList
    private var posts: StringList
    private var ratingScore: Double
    
    init(_ id: String, _ name: String, _ address: String, _ location: CLLocation, _ phone: String, _ types: StringList, _ description: String, _ imagePath: String, _ ratings: RatingList, _ posts: StringList, _ ratingScore: Double) {
        self.id = id
        self.name = name
        self.address = address
        self.location = location
        self.phone = phone
        self.types = types
        self.description = description
        self.imagePath = imagePath
        self.ratings = ratings
        self.posts = posts
        self.ratingScore = ratingScore
    }
    
    convenience init(_ id: String, _ name: String, _ address: String, _ location: CLLocation, _ phone: String, _ types: StringList, _ description: String, _ imagePath: String) {
        self.init(id, name, address, location, phone, types, description, imagePath, RatingList(), StringList(.Post), 0)
    }
    
    convenience init(_ restaurant: ReadOnlyRestaurant) {
        self.init(restaurant.getID(), restaurant.getName(), restaurant.getAddress(), restaurant.getLocation(), restaurant.getPhone(), restaurant.getTypes(), restaurant.getDescription(), restaurant.getImagePath(), restaurant.getRatingsID(), restaurant.getPostsID(), restaurant.getRatingScore() )
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
    func getTypesAsEnum() -> Set<RestaurantType> {
        var typeSet = Set<RestaurantType>()
        for type in self.types.getListAsArray() {
            guard let typeEnum = RestaurantType(rawValue: type) else {
                fatalError("Illegal cuisine type input detected")
            }
            typeSet.insert(typeEnum)
        }
        return typeSet
    }
    func getTypesAsStringSet() -> Set<String> {
        return self.types.getListAsSet()
    }
    func getTypesAsString() -> String {
        var typeString = ""
        self.types.getListAsSet().forEach { typeString += "\($0)  " }
        return typeString
    }
    func setTypes(_ types: [RestaurantType]) {
        var typeStringSet = Set<String>()
        types.forEach { typeStringSet.insert($0.rawValue) }
        self.types = StringList(.RestaurantType, typeStringSet)
    }
    func getImage() -> UIImage {
        
        assert(UIImage(named: self.imagePath) != nil)
        
        if let image = UIImage(named: self.imagePath) {
            return image
        }
        return UIImage()
    }
    func getImagePath() -> String {
        return self.imagePath
    }
    func getPostsID() -> StringList {
        return self.posts
    }
    func getRatingsID() -> RatingList {
        return self.ratings
    }
    func getRatingScore() -> Double {
        return self.ratingScore
    }
    
    // If the user has already rated, update the score; else insert a new rating into the set
    func addRating(_ rating: Rating) {
        let score = rating.getScore()
        self.ratingScore = calcNewRatingScore(Double(score))
        self.ratings.addEntry(rating)
    }
    func addPost(_ post: Post) {
        self.posts.addEntry(post.getPostId())
    }
    func addPosts(_ posts: [Post]) {
        posts.forEach { self.addPost($0)}
    }
    
    private func calcNewRatingScore(_ newScore: Double) -> Double {
        let numOfRating = Double(self.ratings.getListAsSet().count)
        let newAvg = (self.ratingScore * numOfRating + newScore) / (numOfRating + 1)
        return newAvg
    }
    
    func getDistanceToLocation(_ location: CLLocation?) -> Double {
        if let currentLocation = location {
            let distance = currentLocation.distance(from: self.location)
            return Double(round(distance * 10) / 10)
        }
        return 0;
    }
    
    func getUserRating(_ user: User) -> Rating? {
        return self.ratings.findRating(user.getUserId(), self.id)
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
