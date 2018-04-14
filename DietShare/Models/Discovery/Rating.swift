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
class Rating: Codable, Hashable {
    
    private let id: String
    private let userID: String
    private let restaurantID: String
    private let score: RatingScore
    
    
    var hashValue: Int {
        return id.hashValue
    }
    
    static var currentID = 0
    
    init(_ id: String, _ userID: String, _ restaurantID: String, _ score: RatingScore) {
        self.id = id
        self.userID = userID
        self.restaurantID = restaurantID
        self.score = score
    }
    
    convenience init(_ userID: String, _ restaurantID: String, _ score: RatingScore) {
        self.init("\(Rating.currentID + 1)", userID, restaurantID, score)
        Rating.currentID += 1
    }
    
    func getScore() -> Double {
        return self.score.rawValue
    }
    func getID() -> String {
        return self.id
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userID
        case restaurantID
        case score
    }
    
    required init(from decoder: Decoder) throws {
        let value = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try value.decode(String.self, forKey: .id)
        self.userID = try value.decode(String.self, forKey: .userID)
        self.restaurantID = try value.decode(String.self, forKey: .restaurantID)
        let scoreValue = try value.decode(Double.self, forKey: .score)
        guard let score = RatingScore(rawValue: scoreValue) else {
            fatalError("Cannot recover rating score from decoder")
        }
        self.score = score
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id, forKey: .id)
        try container.encode(self.userID, forKey: .userID)
        try container.encode(self.restaurantID, forKey: .restaurantID)
        try container.encode(self.score.rawValue, forKey: .score)
    }
    
    
    static func ==(lhs: Rating, rhs: Rating) -> Bool {
        return lhs.score == rhs.score
    }
}
