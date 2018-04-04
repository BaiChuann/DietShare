//
//  RestaurantLocalDataSource.swift
//  DietShare
//
//  Created by Shuang Yang on 29/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import BTree
import SQLite
import CoreLocation

/**
 * A local data source for Restaurants, implemented with SQLite.
 */
class RestaurantsLocalDataSource: RestaurantsDataSource {
    
    
    private var database: Connection!
    private let restaurantsTable = Table("restaurants")
    
    // Columns of the Restaurants table
    private let id = Expression<String>("id")
    private let name = Expression<String>("name")
    private let image = Expression<UIImage>("image")
    private let description = Expression<String>("description")
    private let address = Expression<String>("address")
    private let location = Expression<CLLocation>("location")
    private let phone = Expression<String>("phone")
    private let type = Expression<String>("type")
    private let posts = Expression<StringList>("posts")
    private let ratings = Expression<StringList>("ratings")
    private let ratingScore = Expression<Double>("ratingScore")
    
    // Initializer is private to prevent instantiation - Singleton Pattern
    private init() {
        print("RestaurantLocalDataSource initializer called")
        createDB()
        createTable()
        prepopulate()
    }
    
    // A shared instance to be used in a global scope
    static let shared = RestaurantsLocalDataSource()
    
    private func createDB() {
        let documentDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        if let fileUrl = documentDirectory?.appendingPathComponent("restaurants").appendingPathExtension("sqlite3") {
            
            self.database = try? Connection(fileUrl.path)
        }
    }
    
    // Creates restaurant table if it is not already existing
    private func createTable() {
        let createTable = self.restaurantsTable.create(ifNotExists: true) { (table) in
            table.column(self.id, primaryKey: true)
            table.column(self.name)
            table.column(self.address)
            table.column(self.location)
            table.column(self.phone)
            table.column(self.type)
            table.column(self.description)
            table.column(self.image)
            table.column(self.ratings)
            table.column(self.posts)
            table.column(self.ratingScore)
        }
        do {
            try self.database.run(createTable)
        } catch {
            fatalError("Database not created")
        }
    }
    
    func getRestaurants() -> SortedSet<Restaurant> {
        var restaurants = SortedSet<Restaurant>()
        do {
            for restaurant in try database.prepare(restaurantsTable) {
                if let restaurantType = RestaurantType(rawValue: restaurant[type]) {
                    let restaurantEntry = Restaurant(restaurant[id], restaurant[name], restaurant[address],restaurant[location], restaurant[phone], restaurantType, restaurant[description], restaurant[image], restaurant[ratings], restaurant[posts], restaurant[ratingScore])
                    restaurants.insert(restaurantEntry)
                }
            }
        } catch let error {
            print("failed to get row: \(error)")
        }
        return restaurants
    }
    
    func addRestaurant(_ newRestaurant: Restaurant) {
        do {
            print("current id is: \(newRestaurant.getID())")
            try database.run(restaurantsTable.insert(id <- newRestaurant.getID(), name <- newRestaurant.getName(), address <- newRestaurant.getAddress(), location <- newRestaurant.getLocation(), phone <- newRestaurant.getPhone(), type <- newRestaurant.getType().rawValue, description <- newRestaurant.getDescription(), image <- newRestaurant.getImage(), ratings <- newRestaurant.getRatingsID(), posts <- newRestaurant.getPostsID(), ratingScore <- newRestaurant.getRatingScore()))
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("insert constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            print("insertion failed: \(error)")
        }
    }
    
    
    func addRestaurants(_ newRestaurants: SortedSet<Restaurant>) {
        for newRestaurant in newRestaurants {
            addRestaurant(newRestaurant)
        }
    }
    
    func containsRestaurant(_ restaurantID: String) -> Bool {
        let row = restaurantsTable.filter(id == restaurantID)
        do {
            if try database.run(row.update(id <- restaurantID)) > 0 {
                return true
            }
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("update constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            print("update failed: \(error)")
        }
        
        return false;
    }
    
    func deleteRestaurant(_ restaurant: Restaurant) {
        let row = restaurantsTable.filter(id == restaurant.getID())
        do {
            if try database.run(row.delete()) > 0 {
                print("deleted the Restaurant")
            } else {
                print("Restaurant not found")
            }
        } catch {
            print("delete failed: \(error)")
        }
    }
    
    func updateRestaurant(_ oldRestaurant: Restaurant, _ newRestaurant: Restaurant) {
        let row = restaurantsTable.filter(id == oldRestaurant.getID())
        do {
            if try database.run(row.update(id <- newRestaurant.getID(), name <- newRestaurant.getName(), address <- newRestaurant.getAddress(), location <- newRestaurant.getLocation(), phone <- newRestaurant.getPhone(), type <- newRestaurant.getType().rawValue, description <- newRestaurant.getDescription(), image <- newRestaurant.getImage(), ratings <- newRestaurant.getRatingsID(), posts <- newRestaurant.getPostsID(), ratingScore <- newRestaurant.getRatingScore())) > 0 {
                print("Old Restaurant is updated")
            } else {
                print("Old Restaurant not found")
            }
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("update constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            print("update failed: \(error)")
        }
    }
    
    /**
     * Test functions - to be removed
     */
    
    // MARK: Only for test purpose
    private func removeDB() {
        print("Remove DB called")
        let documentDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        if let fileUrl = documentDirectory?.appendingPathComponent("topics").appendingPathExtension("sqlite3") {
            try? FileManager.default.removeItem(at: fileUrl)
        }
    }
    
    // Only for testing
    private func prepopulate() {
        print("Prepopulated")
        if !containsRestaurant("1") {
            for i in 0..<20 {
                let location = CLLocation(latitude: 1.35212, longitude: 103.81985)
                let restaurant = Restaurant(String(i), "Salad Heaven", "1 Marina Boulevard, #03-02", location, "98765432", RestaurantType.Vegetarian, "The first Vegetarian-themed salad bar in Singapore. We provide brunch and lunch.", #imageLiteral(resourceName: "vegie-bar"), StringList(.Rating), StringList(.Post), 4.5)
                self.addRestaurant(restaurant)
            }
        }
    }
    
    // TODO - Check representation of the datasource
    private func checkRep() {
        checkNumOfColumn()
    }
    
    private func checkNumOfColumn() {
        
        
    }
    
    
}

// Conform CLLocation to Value for SQLite
extension CLLocation: Value {
    public class var declaredDatatype: String {
        return String.declaredDatatype
    }
    public class func fromDatatypeValue(_ locationString: String) -> CLLocation {
        let coordinates = locationString.components(separatedBy: CharacterSet(charactersIn: "<,>")).flatMap({
            Double($0)
        })
        
        assert(coordinates.count == 2)
        
        let location = CLLocation(latitude: coordinates[0], longitude: coordinates[1])
        return location
    }
    public var datatypeValue: String {
        let locationString = "<\(self.coordinate.latitude),\(self.coordinate.longitude)>"
        return locationString
    }
}

