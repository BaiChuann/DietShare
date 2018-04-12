//
//  PostManager.swift
//  DietShare
//
//  Created by BaiChuan on 31/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class PostManager {
    private var posts: [Post] = []
    private var comments: [String: [Comment]] = [:]
    private var likes: [String: [Like]] = [:]
    private init() {
        let newPost = Post(userId: "1", caption: "today I ate this thing it was super niceeeeee", time: Date(), photo: UIImage(named: "post-example")!, restaurant: ("1", "Koufu"), topics: [("1", "healthy lifestyle"), ("2", "lose weight"), ("3", "don't eat this"), ("4", "salad")])
        for _ in 1...10 {
            posts.append(newPost)
        }
        let postId = newPost.getPostId()
        let newComment = Comment(userId: "1", parentId: postId, content: "This looks so nice", time: Date())
        comments[postId] = []
        for _ in 1...10 {
            if var data = comments[postId] {
                 data.append(newComment)
            }
        }
        let newLike = Like(userId: "1", postId: postId, time: Date())
        likes[postId] = []
        for _ in 1...10 {
            if var data = likes[postId] {
                data.append(newLike)
            }
        }
    }
    static let shared = PostManager()
    func getFollowingPosts() -> [Post] {
        return posts
    }
    func getLikePosts() -> [Post] {
        return posts
    }
    func getDiscoverPosts() -> [Post] {
        return posts
    }
    func getRestaurantPosts(_ id: String) -> [Post] {
        return posts
    }
    func getTopicPosts(_ id: String) -> [Post] {
        return posts
    }
    func getUserPosts(_ id: String) -> [Post] {
        return posts 
    }
    func postPost(caption: String, time: Date, photo: UIImage, restaurant: (String, String)?, topics: [(String, String)]?) -> Post {
        let post = Post(userId: "1", caption: caption, time: time, photo: photo, restaurant: restaurant, topics: topics)
        posts.append(post)
        return post
    }
    func deletePost(_ id: String) -> Bool {
        for i in 0...(posts.count - 1) {
            if posts[i].getPostId() == id {
                posts.remove(at: i)
                return true
            }
        }
        return false
    }
    func getComments(_ postId: String) -> [Comment]? {
        return comments[postId]
    }
    func postComment(_ comment: Comment) -> Comment {
        if var data = comments[comment.getParentId()] {
            data.append(comment)
            return comment
        }
        comments[comment.getParentId()] = [comment]
        return comment
    }
    func getLikes(_ postId: String) -> [Like]? {
        return likes[postId]
    }
    func postLike(_ like: Like) -> Like {
        if var data = likes[like.getPostId()] {
            data.append(like)
            return like
        }
        likes[like.getPostId()] = [like]
        return like
    }
}
