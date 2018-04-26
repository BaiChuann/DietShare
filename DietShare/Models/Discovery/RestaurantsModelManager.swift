//
//  RestaurantsModelManager.swift
//  DietShare
//
//  Created by Shuang Yang on 29/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//
// swiftlint:disable force_cast

import Foundation
import BTree
import CoreLocation

/**
 * A RestaurantsModelManager contains all the restaurant-related model objects and act as a facade to other objects using
 * these models.
 */
class RestaurantsModelManager {
    
    private let userManager = UserModelManager.shared
    private var restaurantsDataSource: RestaurantsDataSource
    private var restaurants: [ReadOnlyRestaurant] {
        return restaurantsDataSource.getAllRestaurants().sorted(by: { $0.getRatingScore() > $1.getRatingScore() })
    }
    
    private init() {
        self.restaurantsDataSource = RestaurantsLocalDataSource.shared
    }
    
    static let shared = RestaurantsModelManager()
    
    func getAllRestaurants() -> [ReadOnlyRestaurant] {
        return self.restaurants
    }
    
    func getSortedRestaurantList(_ sorting: Sorting, _ typeFilters: Set<RestaurantType>, _ currentLocation: CLLocation?) -> [ReadOnlyRestaurant] {
        var restaurantList = [ReadOnlyRestaurant]()
        restaurantList.append(contentsOf: self.restaurants)
        if !typeFilters.isEmpty {
            restaurantList = restaurantList.filter { $0.getTypesAsEnum().overLapsWith(typeFilters) }
        }
        switch sorting {
        case .byRating:
            restaurantList.sort(by: { $0.getRatingScore() > $1.getRatingScore() })
            break
        case .byDistance:
            restaurantList.sort(by: { $0.getDistanceToLocation(currentLocation) < $1.getDistanceToLocation(currentLocation) })
        }
        return restaurantList
    }
    
    func getRestaurantFromID(_ ID: String) -> Restaurant? {
        return self.restaurantsDataSource.getRestaurantFromID(ID)
    }
    
    func getNumOfRestaurants() -> Int {
        return self.restaurantsDataSource.getNumOfRestaurants()
    }
    
    // Obtain a list of restaurants to be displayed in Discover Page
    func getShortList(_ numOfItem: Int) -> [ReadOnlyRestaurant] {
        var displayedList = [ReadOnlyRestaurant]()
        if restaurants.count < numOfItem {
            return restaurants
        }
        for i in 0..<numOfItem {
            displayedList.append(restaurants[i])
        }
        return displayedList
    }
    
    func addRating(restaurantId: String, rate: Int) {
        guard let restaurant = getRestaurantFromID(restaurantId) else {
            return
        }
        guard let userId = userManager.getCurrentUser()?.getUserId() else {
            return
        }
        let rating = Rating(userId, restaurantId, RatingScore(rawValue: rate)!)
        restaurant.addRating(rating)
        self.restaurantsDataSource.updateRestaurant(restaurantId, restaurant)
    }
    
    func addPost(restaurantId: String, post: Post) {
        guard let restaurant = getRestaurantFromID(restaurantId) else {
            return
        }
        restaurant.addPost(post)
        self.restaurantsDataSource.updateRestaurant(restaurantId, restaurant)
    }
}

extension Set where Element == RestaurantType {
    func overLapsWith(_ anotherArray: Set<RestaurantType>) -> Bool {
        for element in self {
            if anotherArray.contains(element) {
                return true
            }
        }
        return false
    }
}
