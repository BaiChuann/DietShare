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

/**
 * A RestaurantsModelManager contains all the restaurant-related model objects and act as a facade to other objects using
 * these models.
 */
class RestaurantsModelManager<T: ReadOnlyRestaurant> {
    private var restaurants: SortedSet<T>
    private var restaurantsDataSource: RestaurantsDataSource
    
    init() {
        self.restaurantsDataSource = RestaurantsLocalDataSource.shared
        self.restaurants = restaurantsDataSource.getAllRestaurants() as! SortedSet<T>
    }
    
    func getFullRestaurantList(_ sorting: Sorting) -> [T] {
        var restaurantList = [T]()
        restaurantList.append(contentsOf: self.restaurants)
        switch sorting {
        case .byRating:
            break
        case .byDistance:
            restaurantList.sort(by: {$0.getDistanceToCurrent() < $1.getDistanceToCurrent()})
        }
        return restaurantList
    }
    
    func getNumOfRestaurants() -> Int {
        return self.restaurantsDataSource.getNumOfRestaurants()
    }
    
    // Obtain a list of restaurants to be displayed in Discover Page
    func getDisplayedList(_ numOfItem: Int) -> [T] {
        var displayedList = [T]()
        var count = 0
        for restaurant in self.restaurants {
            if (count >= numOfItem) {
                break
            }
            displayedList.append(restaurant)
            count += 1
        }
        return displayedList
    }
    
}
