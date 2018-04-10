//
//  LayoutPhotoPreviewCell.swift
//  DietShare
//
//  Created by Fan Weiguang on 31/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class LayoutPhotoPreviewCell: UICollectionViewCell {
    @IBOutlet weak private var previewImage: UIImageView!

    func setImage(_ image: UIImage) {
        previewImage.image = image
    }
}
