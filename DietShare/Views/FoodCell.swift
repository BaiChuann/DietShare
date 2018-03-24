//
//  FoodCell.swift
//  DietShare
//
//  Created by Fan Weiguang on 24/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class FoodCell: UICollectionViewCell {
    @IBOutlet weak private var foodImage: UIImageView!
    @IBOutlet weak private var foodName: UILabel!

    func setFoodImage(_ image: UIImage) {
        foodImage.image = image
    }

    func setFoodName(_ name: String) {
        foodName.text = name
    }
}
