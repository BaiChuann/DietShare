//
//  RawIngredient.swift
//  DietShare
//
//  Created by fanwei on 16/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation

// RawIngredient store the basic info of an ingredient
struct RawIngredient {
    private(set) var name: String
    private(set) var nutrition: [NutritionType: Double]
    
    init(name: String, nutrition: [NutritionType: Double]) {
        self.name = name
        self.nutrition = nutrition
    }
}
