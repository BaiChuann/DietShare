//
//  LikeCell.swift
//  DietShare
//
//  Created by baichuan on 7/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class LikeCell: UITableViewCell {
   
    @IBOutlet weak private var userPhoto: UIImageView!

    @IBOutlet weak private var userName: UILabel!
    func setUser(_ user: User) {
        userPhoto.image = user.getPhoto()
        userName.text = user.getName()
    }
}
