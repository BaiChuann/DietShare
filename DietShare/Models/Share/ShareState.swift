//
//  ShareState.swift
//  DietShare
//
//  Created by Fan Weiguang on 9/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

class ShareState {
    // use food-example-1 for test purpose, should be nil instead
    var originalPhoto = UIImage(named: "food-example-1")
    var food = Food(
        id: 0,
        name: "Watermelon",
        nutrition: [
            NutritionType.fats: 2,
            NutritionType.calories: 245,
            NutritionType.proteins: 90,
            NutritionType.carbohydrate: 150
        ],
        image: UIImage()
    )
    var modifiedPhoto: UIImage?
}
