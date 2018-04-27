//
//  LayoutPhotoPreviewCell.swift
//  DietShare
//
//  Created by Fan Weiguang on 31/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

/*
 A cell for showing the preview of selected photos in the page to select multiple photos
 from library to form a collage.
 */
class LayoutPhotoPreviewCell: UICollectionViewCell {
    @IBOutlet weak private var previewImage: UIImageView!

    func setImage(_ image: UIImage) {
        previewImage.image = image
    }
}
