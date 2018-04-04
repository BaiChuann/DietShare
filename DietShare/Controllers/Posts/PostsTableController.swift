//
//  PostsTableController.swift
//  DietShare
//
//  Created by BaiChuan on 30/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class PostsTableController: UIViewController, UITableViewDataSource, UITableViewDelegate, PostCellDelegate {
    private var dataSource: [Post] = []
    private var postsTable = UITableView()
    private var parentController: UIViewController!
    func retrieveFollowingPosts() {
        dataSource = PostManager.getFollowingPosts()
    }
    func setParentController(_ controller: UIViewController) {
        parentController = controller
    }
    func getTable() -> UITableView {
        let cellNibName = UINib(nibName: "PostCell", bundle: nil)
        postsTable.register(cellNibName, forCellReuseIdentifier: "PostCell")
        postsTable.dataSource = self
        postsTable.delegate = self
        postsTable.rowHeight = UITableViewAutomaticDimension
        postsTable.estimatedRowHeight = 600
        postsTable.reloadData()
        return postsTable
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostCell  else {
            fatalError("The dequeued cell is not an instance of PostCell.")
        }
        let post = dataSource[0]
        cell.setContent(userPhoto: UIImage(named: "profile-example")!, userName: "Bai Chuan", post)
        cell.setDelegate(self)
        print(cell.frame.height)
        return cell
    }
    
    func goToDetail(_ post: Post) {
        let storyboard = UIStoryboard(name: "PostDetail", bundle: Bundle.main)
        if let controller = storyboard.instantiateInitialViewController() as? PostDetailController {
            controller.setPost(post)
            //controller.view.addSubview(postCell)
            print("clicked")
            parentController.view.addSubview(controller.view)
            parentController.tabBarController?.tabBar.isHidden = true
        }
    }
}
