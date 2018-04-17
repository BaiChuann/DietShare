//
//  commentCell.swift
//  DietShare
//
//  Created by baichuan on 7/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {
    
    @IBOutlet weak private var userPhoto: UIButton!
    
    @IBOutlet weak private var userName: UILabel!
    @IBOutlet weak private var time: UILabel!
    @IBOutlet weak private var content: UILabel!
    private var cellDelegate: PostCellDelegate?
    private var comment: Comment!
    func setComment(user: User, comment: Comment) {
        self.comment = comment
        userName.text = user.getName()
        userPhoto.setImage(user.getPhotoAsImage(), for: .normal)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd HH:mm:ss"
        time.text = dateFormatter.string(from: comment.getTime())
        content.text = comment.getContent()
    }
    func setDelegate(_ delegate: PostCellDelegate) {
        self.cellDelegate = delegate
    }
    
    @IBAction func onUserClicked(_ sender: Any) {
        self.cellDelegate?.goToUser("2")
    }
}
