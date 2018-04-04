//
//  PostDetailController.swift
//  DietShare
//
//  Created by baichuan on 4/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class PostDetailController: UIViewController {
    private var post: Post!
    override func viewDidLoad() {
        let postCell = Bundle.main.loadNibNamed("PostCell", owner: nil, options: nil)?.first as! PostCell
        postCell.setContent(userPhoto: UIImage(named: "profile-example")!, userName: "Bai Chu", post)
        postCell.translatesAutoresizingMaskIntoConstraints = false
        print(postCell.frame.height)
        view.addSubview(postCell)
    }
    func setPost(_ post: Post) {
        self.post = post
    }
}

