//
//  Rating.swift
//  DietShare
//
//  Created by Shuang Yang on 29/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation

/**
 * A Rating object represents a rating given by a user to a restaurant.
 */
class Rating {
    private let id: String
    private let userID: String
    private let restaurantID: String
    private let score: RatingScore
    
    init(_ id: String, _ userID: String, _ restaurantID: String, _ score: RatingScore) {
        self.id = id
        self.userID = userID
        self.restaurantID = restaurantID
        self.score = score
    }
    
    func getScore() -> Double {
        return self.score.rawValue
    }
    func getID() -> String {
        return self.id
    }
}
