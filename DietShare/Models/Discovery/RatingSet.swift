//
//  RatingSet.swift
//  DietShare
//
//  Created by Shuang Yang on 15/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation

import SQLite

/**
 * Overview:
 *
 * A RatingSet is a wrapper class for a set of Rating objects.
 *
 * Specification fields:
 *
 * - set: Set<Rating> - a set of ratings
 */

class RatingSet: Equatable, Codable {
    
    private var set: Set<Rating>
    
    enum CodingKeys: String, CodingKey {
        case set
    }
    
    init(_ set: Set<Rating>) {
        self.set = set
    }
    
    convenience init() {
        let set = Set<Rating>()
        self.init(set)
    }
    
    public func getSetAsArray() -> [Rating] {
        var returnSet = [Rating]()
        returnSet.append(contentsOf: self.set)
        return returnSet
    }
    
    public func getSet() -> Set<Rating> {
        return self.set
    }
    
    public func setSet(_ newSet: Set<Rating>) {
        self.set = newSet
    }
    
    // If the user has already rated, update the score; else insert a new rating into the set
    public func addEntry(_ newEntry: Rating) {
        _checkRep()
        if let rating = findRating(newEntry.getUserID(), newEntry.getRestaurantID()) {
            rating.setScore(newEntry.getScoreAsEnum())
        } else {
            self.set.insert(newEntry)
            print("new rating entry inserted")
        }
        _checkRep()
    }
    public func addEntries(_ newEntries: [Rating]) {
        _checkRep()
        for entry in newEntries {
            self.set.insert(entry)
        }
        _checkRep()
    }
    
    public func findRating(_ userID: String, _ restaurantID: String) -> Rating? {
        for rating in self.set {
            if userID == rating.getUserID() && restaurantID == rating.getRestaurantID() {
                return rating
            }
        }
        return nil
    }
    
    static func ==(lhs: RatingSet, rhs: RatingSet) -> Bool {
        return lhs.set == rhs.set
    }
    
    required init(from decoder: Decoder) throws {
        let value = try decoder.container(keyedBy: CodingKeys.self)
        self.set = try value.decode(Set<Rating>.self, forKey: .set)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.set, forKey: .set)
    }
    
    func _checkRep() {
        checkIDUniqueness()
    }
    
    func checkIDUniqueness() {
        var idSet = Set<String>()
        set.forEach { idSet.insert($0.getID()) }
        assert(idSet.count == set.count)
    }
}

extension RatingSet: Value {
    public class var declaredDatatype: String {
        return Blob.declaredDatatype
    }
    public class func fromDatatypeValue(_ blobValue: Blob) -> RatingSet {
        guard let set = try? JSONDecoder().decode(RatingSet.self, from: Data.fromDatatypeValue(blobValue)) else {
            fatalError("IDSet not correctly decoded")
        }
        return set
    }
    public var datatypeValue: Blob {
        guard let setData = try? JSONEncoder().encode(self) else {
            fatalError("IDSet not correctly encoded")
        }
        return setData.datatypeValue
    }
    
}
