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

/**
 * A local data source for Restaurants, implemented with SQLite.
 */
class RestaurantsLocalDataSource: RestaurantsDataSource {
    
    
    private var database: Connection!
    private let restaurantsTable = Table("restaurantsTable")
    
    // Columns of the Restaurants table
    private let id = Expression<String>("id")
    private let name = Expression<String>("name")
    private let image = Expression<UIImage>("image")
    private let description = Expression<String>("description")
    private let address = Expression<String>("address")
    private let phone = Expression<String>("phone")
    private let type = Expression<String>("type")
    private let posts = Expression<IDList>("posts")
    private let ratings = Expression<IDList>("followers")
    private let ratingScore = Expression<Double>("ratingScore")
    
    // Initializer is private to prevent instantiation - Singleton Pattern
    private init() {
        print("initializer called")
        let startTime = CFAbsoluteTimeGetCurrent()
        createDB()
        let timeElapsed = CFAbsoluteTimeGetCurrent() - startTime
        print("Time elapsed for connection: \(timeElapsed) s.")
    }
    
    // A shared instance to be used in a global scope
    static let shared = RestaurantsLocalDataSource()
    
    private func createDB() {
        let documentDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        if let fileUrl = documentDirectory?.appendingPathComponent("RestaurantsTable").appendingPathExtension("sqlite3") {
            
            self.database = try? Connection(fileUrl.path)
            if !FileManager.default.fileExists(atPath: fileUrl.path) {
                createTable()
            }
        }
    }
    
    
    private func createTable() {
        let createTable = self.restaurantsTable.create(block: { (table) in
            table.column(self.id, primaryKey: true)
            table.column(self.name)
            table.column(self.address)
            table.column(self.phone)
            table.column(self.type)
            table.column(self.description)
            table.column(self.image)
            table.column(self.ratings)
            table.column(self.posts)
            table.column(self.ratingScore)
        })
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
                    let restaurantEntry = Restaurant(restaurant[id], restaurant[name], restaurant[address], restaurant[phone], restaurantType, restaurant[description], restaurant[image], restaurant[ratings], restaurant[posts], restaurant[ratingScore])
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
            try database.run(restaurantsTable.insert(id <- newRestaurant.getID(), name <- newRestaurant.getName(), address <- newRestaurant.getAddress(), phone <- newRestaurant.getPhone(), type <- newRestaurant.getType().rawValue, description <- newRestaurant.getDescription(), image <- newRestaurant.getImage(), ratings <- newRestaurant.getRatingsID(), posts <- newRestaurant.getPostsID(), ratingScore <- newRestaurant.getRatingScore()))
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
            if try database.run(row.update(id <- newRestaurant.getID(), name <- newRestaurant.getName(), address <- newRestaurant.getAddress(), phone <- newRestaurant.getPhone(), type <- newRestaurant.getType().rawValue, description <- newRestaurant.getDescription(), image <- newRestaurant.getImage(), ratings <- newRestaurant.getRatingsID(), posts <- newRestaurant.getPostsID(), ratingScore <- newRestaurant.getRatingScore())) > 0 {
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
    
}

