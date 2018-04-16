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
    var name: String {
        return rawInfo.name
    }
    private(set) var image: UIImage
    private(set) var quantity: Int
    private(set) var unit: IngredientUnit
    private(set) var rawInfo: RawIngredient

    init(image: UIImage, quantity: Int, unit: IngredientUnit, rawInfo: RawIngredient) {
        self.image = image
        self.quantity = quantity
        self.unit = unit
        self.rawInfo = rawInfo
    }
}
