//
//  LikeCell.swift
//  DietShare
//
//  Created by baichuan on 7/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit
/**
 * overview
 * This class stores and displays the user name and photo in a table cell
 * used in list of followings, list of followers in profile tab and list of likes in post detail page.
 */
class UserCell: UITableViewCell {
    @IBOutlet weak private var userPhoto: UIImageView!
    @IBOutlet weak private var userName: UILabel!
    func setUser(_ user: User) {
        userPhoto.image = user.getPhotoAsImage()
        userName.text = user.getName()
    }
}
