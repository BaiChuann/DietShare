//
//  Mention.swift
//  DietShare
//
//  Created by BaiChuan on 11/5/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit
/**
 * overview
 * This class display the comment or like on the current user's posts as a table cell.
 * used in mentioned page.
 */
class Mention {
    var userPhoto: UIImage
    var userName: String
    var comment: String
    var postPhoto: UIImage
    var time: Date
    var postId: String!
    init (_ postId: String, _ userPhoto: UIImage, _ userName: String, _ comment: String, _ postPhoto: UIImage, _ time: Date) {
        self.postId = postId
        self.userPhoto = userPhoto
        self.userName = userName
        self.comment = comment
        self.postPhoto = postPhoto
        self.time = time
    }
    func getPostId() -> String {
        return postId
    }
}

