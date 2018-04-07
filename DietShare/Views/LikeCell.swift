//
//  LikeCell.swift
//  DietShare
//
//  Created by baichuan on 7/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class LikeCell: UICollectionViewCell {
    @IBOutlet weak private var userPhoto: UIImageView!
    func setPhoto(_ photo: UIImage) {
        userPhoto.image = photo
    }
}
