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
        self.backgroundColor = Constants.lightBackgroundColor
    }
}
