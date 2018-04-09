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
        self.restaurants = restaurantsDataSource.getRestaurants() as! SortedSet<T>
        
        // Prepopulate the datasource - only for testing
        prepopulate()
    }
    
    func getFullRestaurantList() -> [T] {
        var restaurantList = [T]()
        restaurantList.append(contentsOf: self.restaurants)
        return restaurantList
    }
    
    // Obtain a list of restaurants to be displayed in Discover Page
    func getDisplayedList() -> [T] {
        var displayedList = [T]()
        var count = 0
        for restaurant in self.restaurants {
            if (count >= Constants.DiscoveryPage.numOfDisplayedRestaurants) {
                break
            }
            displayedList.append(restaurant)
            count += 1
        }
        return displayedList
    }
    
    private func prepopulate() {
        for i in 0..<20 {
            let restaurant = Restaurant(String(i), "Vege Heaven", "27 Prince George's Park", "99991111", .Vegetarian, "Best vegetarian place ever!", #imageLiteral(resourceName: "vegi-life"))
            self.restaurantsDataSource.addRestaurant(restaurant)
        }
    }
    
}
