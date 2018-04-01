//
//  PostManager.swift
//  DietShare
//
//  Created by BaiChuan on 31/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class PostManager {
    private static var posts: [Post] = []
    static func loadData() {
        let newPost = Post(userId: "1", caption: "this is a example of caption, this is a example of caption, this is a example of caption", time: Date(), photo: UIImage(named: "food-result-1")!, restaurant: ("1", "Koufu"), topic: [("1", "healthy lifestyle")])
        posts.append(newPost)
    }
    static func getFollowingPosts() -> [Post] {
        return posts
    }
}
