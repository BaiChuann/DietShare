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
        let newPost = Post(userId: "1", caption: "this is a example of caption, this is a example of caption, this is a example of caption", time: Date(), photo: UIImage(named: "post-example")!, restaurant: ("1", "Koufu"), topics: [("1", "healthy lifestyle"), ("2", "lose weight"), ("3", "don't eat this"), ("4", "salad")])
        posts.append(newPost)
    }
    static func getFollowingPosts() -> [Post] {
        return posts
    }
}
