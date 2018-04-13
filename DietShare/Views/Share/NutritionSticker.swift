//
//  NutritionSticker.swift
//  DietShare
//
//  Created by fanwei on 14/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class NutritionSticker: UIView {
    @IBOutlet private weak var foodName: UILabel!
    @IBOutlet private weak var calories: UILabel!
    @IBOutlet private var nutritionType: [UILabel]!
    @IBOutlet private var nutritionAmount: [UILabel]!
    
    private let nutritionTypeDict = [NutritionType.fats, NutritionType.proteins, NutritionType.carbohydrate]
}
