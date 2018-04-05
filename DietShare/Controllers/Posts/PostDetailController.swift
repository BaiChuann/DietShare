//
//  PostDetailController.swift
//  DietShare
//
//  Created by baichuan on 4/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class PostDetailController: UIViewController {
    private weak var post: PostCell!
    @IBOutlet weak private var postArea: UIView!
    @IBOutlet weak var postCell: PostCell!
    override func viewDidLoad() {
//        let postCell = Bundle.main.loadNibNamed("PostCell", owner: nil, options: nil)?.first as! PostCell
        postCell.setContent(userPhoto: UIImage(named: "profile-example")!, userName: "Bai Chu", post.getPost())
        //postCell.translatesAutoresizingMaskIntoConstraints = false
        //postArea.frame.size = CGSize(width: postArea.frame.width, height: UITableViewAutomaticDimension)
        //postArea.addSubview(postCell)

       
        
        
    }
    @IBAction func onBackClicked(_ sender: Any) {
        print("back")
        self.willMove(toParentViewController: nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        
    }
    func setPost(_ post: PostCell) {
        self.post = post
    }
}

