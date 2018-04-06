//
//  RestaurantsDataSource.swift
//  DietShare
//
//  Created by Shuang Yang on 29/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import BTree

/**
 * A protocol for a data source for restaurants only.
 * Implementations should guarantee: details are present and not null, field values are validated.
 */
protocol RestaurantsDataSource {
    func getRestaurants() -> SortedSet<Restaurant>
    func addRestaurant(_ newRestaurant: Restaurant)
    func addRestaurants(_ newRestaurants: SortedSet<Restaurant>)
    func deleteRestaurant(_ newRestaurant: Restaurant)
    func updateRestaurant(_ oldRestaurant: Restaurant, _ newRestaurant: Restaurant)
}
