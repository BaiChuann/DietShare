//
//  commentCell.swift
//  DietShare
//
//  Created by baichuan on 7/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    @IBOutlet weak private var userPhoto: UIImageView!
    
    @IBOutlet weak private var userName: UILabel!
    @IBOutlet weak private var time: UILabel!
    @IBOutlet weak private var content: UILabel!
    private var comment: Comment!
    func setComment(user: User, comment: Comment) {
        self.comment = comment
        userName.text = user.getName()
        userPhoto.image = user.getPhotoAsImage()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd HH:mm:ss"
        time.text = dateFormatter.string(from: comment.getTime())
        content.text = comment.getContent()
    }
}
