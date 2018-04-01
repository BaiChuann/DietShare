//
//  PostsTableController.swift
//  DietShare
//
//  Created by BaiChuan on 30/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class PostsTableController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var dataSource: [Post] = []
    private var postsTable = UITableView()
    func retrieveFollowingPosts() {
        dataSource = PostManager.getFollowingPosts()
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
        cell.setUserPhoto(UIImage(named: "food-result-1")!)
        cell.setUserName("Bai Chuan")
        cell.setPostImage(post.getPhoto())
        cell.setCaption(post.getCaption())
        cell.setLikeCount(String(post.getLikesCount()))
        cell.setCommentCount(String(post.getCommentsCount()))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd HH:mm:ss"
        cell.setTime(dateFormatter.string(from:post.getTime()))
        cell.setTopic(post.getTopic()[0].1)
        cell.setRestaurant(post.getRestaurant().1)
        return cell
    }
}
