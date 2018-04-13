//
//  NutritionSticker.swift
//  DietShare
//
//  Created by fanwei on 14/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit
import LinearProgressView

class NutritionSticker: UIView {
    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var foodName: UILabel!
    @IBOutlet private weak var calories: UILabel!
    @IBOutlet private var nutritionNames: [UILabel]!
    @IBOutlet private var nutritionAmount: [UILabel]!
    @IBOutlet private var nutritionAmountBar: [LinearProgressView]!

    private let nutritionTypesInOrder = [NutritionType.fats, NutritionType.proteins, NutritionType.carbohydrate]
    private let colorsInOrder = ["#F6C83D", "#F45254", "#71CDD9"]

    override init(frame: CGRect) {
        super.init(frame: frame)
        initXib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initXib()
    }

    private func initXib() {
        Bundle.main.loadNibNamed("NutritionSticker", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }

    func setData(food: Food) {
        foodName.text = food.name
        calories.text = String(format: "%.0fCal", food.nutrition[NutritionType.calories] ?? 0)
        nutritionNames.forEach {
            $0.text = nutritionTypesInOrder[$0.tag].rawValue
        }
        nutritionAmount.forEach {
            $0.text = String(format: "%.0fg", food.nutrition[nutritionTypesInOrder[$0.tag]] ?? 0)
        }
        nutritionAmountBar.forEach { bar in
            bar.trackColor = hexToUIColor(hex: colorsInOrder[bar.tag])
            bar.maximumValue = 300

            UIView.animate(withDuration: 0.3) {
                bar.setProgress(Float(food.nutrition[self.nutritionTypesInOrder[bar.tag]] ?? 0), animated: true)
            }
        }
    }
}
