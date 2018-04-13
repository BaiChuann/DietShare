//
//  Food.swift
//  DietShare
//
//  Created by Fan Weiguang on 24/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

enum NutritionType: String {
    case fats = "Fats"
    case proteins = "Proteins"
    case carbohydrate = "Carbohydrate"
    case calories = "Cal"
}

struct Food {
    private(set) var id: Int
    private(set) var name: String
    private(set) var image: UIImage
    private(set) var nutrition: [NutritionType: Double]
    private(set) var ingredients: [Ingredient]?
    var isFood: Bool {
        return name != "Not Food"
    }

    // Init food from recognition
    init(id: Int, name: String, nutrition: [NutritionType: Double], image: UIImage) {
        self.id = id
        self.name = name
        self.nutrition = nutrition
        self.image = image
    }

    // Init food added by user
    init(name: String, image: UIImage, ingredients: [Ingredient]) {
        self.id = 0
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
