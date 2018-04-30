//
//  RestaurantsLocalDataSourceTest.swift
//  DietShareTests
//
//  Created by Shuang Yang on 10/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import XCTest
import CoreLocation
@testable import DietShare

class RestaurantsLocalDataSourceTest: XCTestCase {
    
    private final var testDataSource: RestaurantsLocalDataSource?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetRestaurants() {
        var restaurants = [Restaurant]()
        let testDataSource0 = RestaurantsLocalDataSource.getTestInstance(restaurants, "test0")
        XCTAssert(testDataSource0.getAllRestaurants().count == restaurants.count, "Incorrect list of restaurants obtained")
        XCTAssert(testDataSource0.getNumOfRestaurants() == 0, "Incorrect number of restaurants obtained")
        XCTAssert(testDataSource0.getRestaurantFromID("1") == nil, "Incorrect restaurant obtained")
        
        let restaurant1 = Restaurant("1", "test1")
        restaurants.append(restaurant1)
        let testDataSource1 = RestaurantsLocalDataSource.getTestInstance(restaurants)
        XCTAssert(testDataSource1.getAllRestaurants().count == restaurants.count, "Incorrect list of restaurants obtained")
        XCTAssert(testDataSource1.getNumOfRestaurants() == 1, "Incorrect number of restaurants obtained")
        XCTAssert(testDataSource1.getRestaurantFromID("1")! == restaurant1, "Incorrect restaurant obtained")
        
        let restaurant2 = Restaurant("2", "test2")
        restaurants.append(restaurant2)
        let testDataSource2 = RestaurantsLocalDataSource.getTestInstance(restaurants)
        XCTAssert(testDataSource2.getAllRestaurants().count == restaurants.count, "Incorrect list of restaurants obtained")
        XCTAssert(testDataSource2.getNumOfRestaurants() == 2, "Incorrect number of restaurants obtained")
        XCTAssert(testDataSource2.getRestaurantFromID("2")! == restaurant2, "Incorrect restaurant obtained")
        
        testDataSource0.removeDB(Constants.Tables.restaurants + "test0")
        testDataSource1.removeDB(Constants.Tables.restaurants + "test1")
        testDataSource2.removeDB(Constants.Tables.restaurants + "test2")
    }
    
    func testAddRestaurant() {
        var restaurants = [Restaurant]()
        let testDataSource0 = RestaurantsLocalDataSource.getTestInstance(restaurants, "test0")
        XCTAssert(testDataSource0.getNumOfRestaurants() == 0, "Incorrect number of restaurants obtained")
        // Add restaurant
        let restaurant1 = Restaurant("1", "test1")
        testDataSource0.addRestaurant(restaurant1)
        XCTAssert(testDataSource0.getNumOfRestaurants() == 1, "Incorrect number of restaurants obtained")
        XCTAssert(testDataSource0.getRestaurantFromID("1")! == restaurant1, "Incorrect restaurant obtained")
        XCTAssert(testDataSource0.containsRestaurant(restaurant1.getID()), "Incorrect restaurant obtained")
        
        // Add duplicate restaurant
        testDataSource0.addRestaurant(restaurant1)
        XCTAssert(testDataSource0.getNumOfRestaurants() == 1, "Incorrect number of restaurants obtained")
        XCTAssert(testDataSource0.getRestaurantFromID("1")! == restaurant1, "Incorrect restaurant obtained")
        XCTAssert(testDataSource0.containsRestaurant(restaurant1.getID()), "Incorrect restaurant obtained")
        
        // Add multiple restaurants
        let restaurant2 = Restaurant("2", "test2")
        let restaurant3 = Restaurant("3", "test3")
        restaurants.append(restaurant2)
        restaurants.append(restaurant3)
        testDataSource0.addRestaurants(restaurants)
        XCTAssert(testDataSource0.getNumOfRestaurants() == 3, "Incorrect number of restaurants obtained")
        XCTAssert(testDataSource0.getRestaurantFromID("1")! == restaurant1, "Incorrect restaurant obtained")
        XCTAssert(testDataSource0.getRestaurantFromID("2")! == restaurant2, "Incorrect restaurant obtained")
        XCTAssert(testDataSource0.getRestaurantFromID("3")! == restaurant3, "Incorrect restaurant obtained")
        XCTAssert(testDataSource0.containsRestaurant(restaurant1.getID()), "Incorrect restaurant obtained")
        XCTAssert(testDataSource0.containsRestaurant(restaurant2.getID()), "Incorrect restaurant obtained")
        XCTAssert(testDataSource0.containsRestaurant(restaurant3.getID()), "Incorrect restaurant obtained")
        
        testDataSource0.removeDB(Constants.Tables.restaurants + "test0")
    }
    
    func testDeleteRestaurant() {
        let restaurants = [Restaurant]()
        let testDataSource0 = RestaurantsLocalDataSource.getTestInstance(restaurants, "test0")
        XCTAssert(testDataSource0.getNumOfRestaurants() == 0, "Incorrect number of restaurants obtained")
        
        let restaurant1 = Restaurant("1", "test1")
        testDataSource0.addRestaurant(restaurant1)
        XCTAssert(testDataSource0.getNumOfRestaurants() == 1, "Incorrect number of restaurants obtained")
        XCTAssert(testDataSource0.containsRestaurant(restaurant1.getID()), "Incorrect restaurant obtained")
        
        testDataSource0.deleteRestaurant(restaurant1.getID())
        XCTAssert(testDataSource0.getNumOfRestaurants() == 0, "Incorrect number of restaurants obtained")
        XCTAssert(!testDataSource0.containsRestaurant(restaurant1.getID()), "Incorrect restaurant obtained")
        
        testDataSource0.removeDB(Constants.Tables.restaurants + "test0")
    }
    
    func testUpdateRestaurant() {
        let restaurants = [Restaurant]()
        let testDataSource0 = RestaurantsLocalDataSource.getTestInstance(restaurants, "test0")
        XCTAssert(testDataSource0.getNumOfRestaurants() == 0, "Incorrect number of restaurants obtained")
        
        let restaurant1 = Restaurant("1", "test1")
        testDataSource0.addRestaurant(restaurant1)
        XCTAssert(testDataSource0.getNumOfRestaurants() == 1, "Incorrect number of restaurants obtained")
        
        restaurant1.setName("test1.1")
        testDataSource0.updateRestaurant(restaurant1.getID(), restaurant1)
        XCTAssert(testDataSource0.getNumOfRestaurants() == 1, "Incorrect number of restaurants obtained")
        XCTAssert(testDataSource0.containsRestaurant(restaurant1.getID()), "Incorrect restaurant obtained")
    XCTAssert(testDataSource0.getRestaurantFromID(restaurant1.getID())?.getName() == restaurant1.getName(), "Incorrect restaurant obtained")
        
        testDataSource0.removeDB(Constants.Tables.restaurants + "test0")
    }
    
    func testSearchByKeyword() {
        let restaurantWithKeyword = Restaurant("withKeyword", Constants.Test.withKeyword)
        let restaurantWithoutKeyword = Restaurant("WithoutKeyword", Constants.Test.withoutKeyword)
        
        var restaurants = [restaurantWithKeyword, restaurantWithoutKeyword]
        testDataSource = RestaurantsLocalDataSource.getTestInstance(restaurants)
        if let searchResult = testDataSource?.searchWithKeyword(Constants.Test.keyword) {
            XCTAssert(searchResult.count == 1, "Incorrect number of search result")
            XCTAssert(searchResult[0] == restaurantWithKeyword, "Incorrect search result")
        }
        
        let restaurantWithEmpty = Restaurant(" ", " ")
        restaurants.append(restaurantWithEmpty)
        testDataSource = RestaurantsLocalDataSource.getTestInstance(restaurants)
        if let searchResult = testDataSource?.searchWithKeyword(Constants.Test.keyword) {
            XCTAssert(searchResult.count == 1, "Incorrect number of search result")
            XCTAssert(searchResult[0] == restaurantWithKeyword, "Incorrect search result")
        }
        
        let restaurantWithKeywordHighRating = Restaurant("withKeyword2", Constants.Test.withKeyword + "HighRating", 5)
        restaurants.append(restaurantWithKeywordHighRating)
        testDataSource = RestaurantsLocalDataSource.getTestInstance(restaurants)
        if let searchResult = testDataSource?.searchWithKeyword(Constants.Test.keyword) {
            XCTAssert(searchResult.count == 2, "Incorrect number of search result")
            XCTAssert(searchResult[0] == restaurantWithKeywordHighRating, "Restaurants are not ranked in the correct descending order of popularity")
            XCTAssert(searchResult[1] == restaurantWithKeyword, "Restaurants are not ranked in the correct descending order of popularity")
        }
    }
    
}

extension Restaurant {
    convenience init(_ id: String, _ name: String) {
        self.init(id, name, " ", CLLocation(), " ", StringList(.RestaurantType), " ", "vegie-bar", RatingSet(), StringList(.Post), 0)
    }
    
    convenience init(_ id: String, _ name: String, _ score: Double) {
        self.init(id, name, " ", CLLocation(), " ", StringList(.RestaurantType), " ", "vegie-bar", RatingSet(), StringList(.Post), score)
    }
}
