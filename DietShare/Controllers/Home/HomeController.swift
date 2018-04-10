//
//  HomeController.swift
//  DietShare
//
//  Created by BaiChuan on 30/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class HomeController: UIViewController {
    private var postsTableController: PostsTableController!
    @IBOutlet weak private var postsArea: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        PostManager.loadData()
        postsTableController = PostsTableController()
        postsTableController.retrieveFollowingPosts()
        let postsTable = postsTableController.getTable()
        postsTable.frame = postsArea.frame
        postsArea.addSubview(postsTable)
        
    }
    
}
