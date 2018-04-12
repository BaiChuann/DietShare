//
//  Food.swift
//  DietShare
//
//  Created by Fan Weiguang on 24/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

enum NutritionType {
    case fats, proteins, carbohydrate, calories
}

struct Food {
    private(set) var name: String
    private(set) var image: UIImage
    private(set) var nutrition: [NutritionType: Int]
    private(set) var ingredients: [Ingredient]?

    // Init food from recognition
    init(name: String, image: UIImage) {
        self.name = name
        self.image = image
        self.nutrition = [
            NutritionType.fats: 220,
            NutritionType.proteins: 150,
            NutritionType.carbohydrate: 100,
            NutritionType.calories: 445
        ]
    }

    // Init food added by user
    init(name: String, image: UIImage, ingredients: [Ingredient]) {
        self.name = name
        self.image = image
        self.ingredients = ingredients
        self.nutrition = [
            NutritionType.fats: 220,
            NutritionType.proteins: 150,
            NutritionType.carbohydrate: 100,
            NutritionType.calories: 445
        ]
    }
}
