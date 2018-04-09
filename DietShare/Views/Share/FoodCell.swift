//
//  FoodCell.swift
//  DietShare
//
//  Created by Fan Weiguang on 24/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class FoodCell: UICollectionViewCell {
    @IBOutlet weak private var background: UIView!
    @IBOutlet weak private var foodImage: UIImageView!
    @IBOutlet weak private var foodName: UILabel!

    override func layoutSubviews() {
        background.layer.cornerRadius = Constants.cornerRadius
        background.layer.masksToBounds = true

        foodName.layer.shadowColor = Constants.darkTextColor.cgColor
        foodName.layer.shadowRadius = 2.0
        foodName.layer.shadowOpacity = 0.4
        foodName.layer.shadowOffset = CGSize(width: 2, height: 2)
        foodName.layer.masksToBounds = false

        super.layoutSubviews()
    }

    func setFoodImage(_ image: UIImage) {
        foodImage.image = image
    }

    func setFoodName(_ name: String) {
        foodName.text = name
    }

    func setSelected() {
        background.backgroundColor = UIColor.black
    }
}
