//
//  ReadOnlyRestaurant.swift
//  DietShare
//
//  Created by Shuang Yang on 26/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation

/**
 * A read-only immutable protocol for a Restaurant in the app.
 * Implementations should guarantee: details are present and not null, field values are validated.
 */
protocol ReadOnlyRestaurant: Comparable {
    func getID() -> String
    func getName() -> String
    func getType() -> RestaurantType
    func getPhone() -> String
    func getDescription() -> String
    func getImage() -> UIImage
    func getAddress() -> String
    func getLocation() -> CLLocation
    func getPostsID() -> StringList
    func getRatingsID() -> StringList
    func getRatingScore() -> Double
}
