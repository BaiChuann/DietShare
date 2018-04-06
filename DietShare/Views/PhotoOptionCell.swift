//
//  PhotoOptionCell.swift
//  DietShare
//
//  Created by Fan Weiguang on 30/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class PhotoOptionCell: UICollectionViewCell {
    @IBOutlet weak private var optionImage: UIImageView!

    func setOptionImage(_ image: UIImage) {
        optionImage.image = image
    }

    func clearImage() {
        optionImage.image = nil
    }

    func setSelected() {
        print("set cell selected")
        optionImage.alpha = 0.5
    }

    func setUnselected() {
        print("set cell unselected")
        optionImage.alpha = 1
    }
}
