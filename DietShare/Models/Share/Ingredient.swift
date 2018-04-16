//
//  Ingredient.swift
//  DietShare
//
//  Created by Fan Weiguang on 24/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

enum IngredientUnit {
    case sBowl, mBowl, mPlate, lPlate
}

struct Ingredient {
    private(set) var name: String
    private(set) var image: UIImage
    private(set) var quantity: Int
    private(set) var unit: IngredientUnit

    init(name: String, image: UIImage, quantity: Int, unit: IngredientUnit) {
        self.name = name
        self.image = image
        self.quantity = quantity
        self.unit = unit
    }
}
