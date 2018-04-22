//
//  ActiveUserList.swift
//  DietShare
//
//  Created by Shuang Yang on 27/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

class ActiveUserList: UICollectionViewCell {
    
    @IBOutlet weak var imageHolder: UIView!
    @IBOutlet weak private var userImage: UIImageView!
    @IBOutlet weak private var userName: UILabel!
    
    func setImage(_ image: UIImage) {
        userImage.image = image
//        userImage = makeRoundImg(img: userImage)
        addRoundedRectBackground(userImage, userImage.frame.width / 2, 0, UIColor.clear.cgColor, UIColor.clear)
        addShadowToView(view: self.imageHolder, offset: 2, radius: 2)
    }
    
    func setName(_ name: String) {
        userName.text = name
    }
    
    func getImage() -> UIImageView {
        return self.userImage
    }
    
}

