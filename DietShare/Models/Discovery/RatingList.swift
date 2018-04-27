//
//  RatingList.swift
//  DietShare
//
//  Created by Shuang Yang on 15/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation

import SQLite

class RatingList: Equatable, Codable {
    
    private var list: Set<Rating>
    
    enum CodingKeys: String, CodingKey {
        case list
    }
    
    init(_ list: Set<Rating>) {
        self.list = list
    }
    
    convenience init() {
        let list = Set<Rating>()
        self.init(list)
    }
    
    public func getListAsArray() -> [Rating] {
        var returnList = [Rating]()
        returnList.append(contentsOf: self.list)
        return returnList
    }
    
    public func getListAsSet() -> Set<Rating> {
        return self.list
    }
    
    public func setList(_ newList: Set<Rating>) {
        self.list = newList
    }
    
    // If the user has already rated, update the score; else insert a new rating into the set
    public func addEntry(_ newEntry: Rating) {
        _checkRep()
        if let rating = findRating(newEntry.getUserID(), newEntry.getRestaurantID()) {
            rating.setScore(newEntry.getScoreAsEnum())
        } else {
            self.list.insert(newEntry)
            print("new rating entry inserted")
        }
        _checkRep()
    }
    public func addEntries(_ newEntries: [Rating]) {
        _checkRep()
        for entry in newEntries {
            self.list.insert(entry)
        }
        _checkRep()
    }
    
    public func findRating(_ userID: String, _ restaurantID: String) -> Rating? {
        for rating in self.list {
            if userID == rating.getUserID() && restaurantID == rating.getRestaurantID() {
                return rating
            }
        }
        return nil
    }
    
    static func ==(lhs: RatingList, rhs: RatingList) -> Bool {
        return lhs.list == rhs.list
    }
    
    required init(from decoder: Decoder) throws {
        let value = try decoder.container(keyedBy: CodingKeys.self)
        self.list = try value.decode(Set<Rating>.self, forKey: .list)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.list, forKey: .list)
    }
    
    func _checkRep() {
        checkIDUniqueness()
    }
    
    func checkIDUniqueness() {
        var idSet = Set<String>()
        list.forEach { idSet.insert($0.getID()) }
        assert(idSet.count == list.count)
    }
}

extension RatingList: Value {
    public class var declaredDatatype: String {
        return Blob.declaredDatatype
    }
    public class func fromDatatypeValue(_ blobValue: Blob) -> RatingList {
        guard let list = try? JSONDecoder().decode(RatingList.self, from: Data.fromDatatypeValue(blobValue)) else {
            fatalError("IDList not correctly decoded")
        }
        return list
    }
    public var datatypeValue: Blob {
        guard let listData = try? JSONEncoder().encode(self) else {
            fatalError("IDList not correctly encoded")
        }
        return listData.datatypeValue
    }
    
}
