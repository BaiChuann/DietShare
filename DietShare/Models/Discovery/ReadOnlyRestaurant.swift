//
//  ReadOnlyRestaurant.swift
//  DietShare
//
//  Created by Shuang Yang on 26/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation

protocol ReadOnlyRestaurant {
    func getID() -> String
    func getName() -> String
    func getDescription() -> String
    func getAddress() -> String
}
