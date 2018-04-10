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
            XCTAssert(searchResult[0] == restaurantWithKeywordHighRating, "Topics are not ranked in the correct descending order of popularity")
            XCTAssert(searchResult[1] == restaurantWithKeyword, "Topics are not ranked in the correct descending order of popularity")
        }
    }
    
}

extension Restaurant {
    convenience init(_ id: String, _ name: String) {
        self.init(id, name, " ", CLLocation(), " ", StringList(.RestaurantType), " ", "vegie-bar", StringList(.Rating), StringList(.Post), 0)
    }
    
    convenience init(_ id: String, _ name: String, _ score: Double) {
        self.init(id, name, " ", CLLocation(), " ", StringList(.RestaurantType), " ", "vegie-bar", StringList(.Rating), StringList(.Post), score)
    }
}





