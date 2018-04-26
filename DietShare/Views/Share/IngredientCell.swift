//
//  IngredientCell.swift
//  DietShare
//
//  Created by Fan Weiguang on 24/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

/*
 This cell serves as the collection view cell in the custom food adding page.
 It contains an image and name of the ingredient.

 Currently on UI only the name is displayed, as the database for fetching the image
 of the ingredient hasn't completed yet(done by NeXT research center side).
 */
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
