//
//  MentionedCell.swift
//  DietShare
//
//  Created by baichuan on 15/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class MentionedCell: UITableViewCell {
    
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var like: UIImageView!
    @IBOutlet weak var postPhoto: UIImageView!
    @IBOutlet weak var time: UILabel!
    func setContent(_ userPhoto: UIImage, _ userName: String, _ comment: String, _ postPhoto: UIImage, _ time: Date) {
        self.userPhoto.image = userPhoto
        self.userName.text = userName
        if comment == "" {
            self.comment.isHidden = true
        } else {
            self.comment.text = comment
            self.like.isHidden = true
        }
        self.postPhoto.image = postPhoto
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd HH:mm:ss"
        self.time.text = dateFormatter.string(from: time)
    }
}
