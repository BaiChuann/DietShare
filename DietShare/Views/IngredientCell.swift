//
//  IngredientCell.swift
//  DietShare
//
//  Created by Fan Weiguang on 24/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class IngredientCell: UICollectionViewCell {
    @IBOutlet weak private var imageView: UIImageView!
    @IBOutlet weak private var nameLabel: UILabel!

    func setImage(_ image: UIImage?) {
        imageView.image = image
    }

    func setName(_ name: String) {
        nameLabel.text = name
    }
}
