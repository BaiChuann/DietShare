//
//  ActiveUserListCell.swift
//  DietShare
//
//  Created by Shuang Yang on 27/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

class ActiveUserListCell: UICollectionViewCell {
    
    @IBOutlet weak private var userImage: UIImageView!
    @IBOutlet weak private var userName: UILabel!
    
    func setImage(_ image: UIImage) {
        userImage.image = image
    }
    
    func setName(_ name: String) {
        userName.text = name
    }
    
}

