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
    @IBOutlet weak private var nutritionStack: UIStackView!
    @IBOutlet weak private var separator: UIView!
    @IBOutlet weak private var nameHeightConstraint: NSLayoutConstraint!
    
    private let nutritionTypesInOrder = [NutritionType.fats, NutritionType.proteins, NutritionType.carbohydrate]
    private let colorsInOrder = ["#F6C83D", "#F45254", "#71CDD9"]
    private var originalSize = CGSize.zero
    private var hasData = false

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
        contentView.layer.cornerRadius = Constants.cornerRadius
    }
    
    func isDataInitialised() -> Bool {
        return hasData
    }

    func setData(food: Food) {
        foodName.text = food.name
        originalSize = foodName.frame.size
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

            UIView.animate(withDuration: 0.5) {
                bar.setProgress(Float(food.nutrition[self.nutritionTypesInOrder[bar.tag]] ?? 0), animated: true)
            }
        }
        
        hasData = true
    }
    
    func getSizeDelta() -> CGSize {
        guard let text = foodName.text else {
            return .zero
        }
        
        let labelTextSize = (text as NSString).boundingRect(
            with: CGSize(width: frame.size.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: foodName.font],
            context: nil
            ).size
        let maxWidth = 1.3 * foodName.frame.width
        var newSize = foodName.frame.size
        if labelTextSize.width > maxWidth {
            newSize = CGSize(width: maxWidth, height: originalSize.height * 2)
        } else if labelTextSize.width > foodName.frame.width {
            newSize = CGSize(width: labelTextSize.width + 1, height: originalSize.height)
        }
        return CGSize(width: newSize.width - foodName.frame.width, height: newSize.height - originalSize.height)
    }
    
    func updateLabelSize(with size: CGSize) {
        nameHeightConstraint.constant = nameHeightConstraint.constant + size.height
    }
}
