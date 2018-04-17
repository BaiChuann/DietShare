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
    private var comments: [Comment] = []
    private var likes: [Like] = []
    private var userManager = UserModelManager.shared
    private var profileManager = ProfileManager.shared
   // private var postsDataSource = PostsLocalDataSource.shared
    private var currentUser: User
    private init() {
   //     posts = postsDataSource.getAllPosts()
        currentUser = userManager.getCurrentUser()!
        for i in 1...20 {
            let newPost = Post(userId: "1", caption: "today I ate this thing it was super niceeeeee", time: Date(), photo: UIImage(named: "post-example")!, restaurant: "1", topics: ["1", "2", "3", "4", "5"])
            posts.append(newPost)
        }
        for i in 2...10 {
            let newPost = Post(userId: String(i), caption: "today I ate this thing it was super niceeeeee", time: Date(), photo: UIImage(named: "post-example")!, restaurant: "1", topics: ["1", "2", "3", "4", "5"])
            posts.append(newPost)
        }
        let postId = posts[0].getPostId()
        let newComment = Comment(userId: "3", parentId: postId, content: "This looks so nice", time: Date())
        for _ in 1...10 {
             comments.append(newComment)
        }
        let newLike = Like(userId: "3", postId: postId, time: Date())
        for _ in 1...10 {
            likes.append(newLike)
        }
    }
    static let shared = PostManager()
    func getPost(_ id: String) -> Post? {
        for post in posts {
            if post.getPostId() == id {
                return post
            }
        }
        return nil
    }
    func getFollowingPosts() -> [Post] {
        var results: [Post] = []
        let followingUsers = profileManager.getFollowingUsers(currentUser.getUserId())
        for post in posts {
            if followingUsers.contains(post.getUserId()) {
                results.append(post)
            }
        }
        return results.sorted(by: {$0.getTime() > $1.getTime()})
    }
    func getLikePosts() -> [Post] {
        var results: [Post] = []
        for like in likes {
            if like.getUserId() == currentUser.getUserId() {
                guard let post = getPost(like.getPostId()) else {
                    return []
                }
                results.append(post)
            }
        }
        return results.sorted(by: {$0.getTime() > $1.getTime()})
    }
    func getTrendingPosts() -> [Post] {
        let sortedPosts = posts.sorted(by: {$0.getLikesCount() > $1.getLikesCount()})
        return sortedPosts
    }
    func getRestaurantPosts(_ id: String) -> [Post] {
        var results: [Post] = []
        for post in posts {
            guard let res = post.getRestaurant() else {
                continue
            }
            if res == id {
                results.append(post)
            }
        }
        return results.sorted(by: {$0.getTime() > $1.getTime()})
    }
    func getTopicPosts(_ id: String) -> [Post] {
        var results: [Post] = []
        for post in posts {
            guard let topics = post.getTopics() else {
                continue
            }
            for topic in topics {
                if topic == id {
                    results.append(post)
                    break
                }
            }
        }
        return results.sorted(by: {$0.getTime() > $1.getTime()})
    }
    func getUserPosts(_ id: String) -> [Post] {
        return (posts.filter { $0.getUserId() == id }).sorted(by: {$0.getTime() > $1.getTime()})
    }
    func postPost(caption: String, time: Date, photo: UIImage, restaurant: String?, topics: [String]?) -> Post {
        let post = Post(userId: currentUser.getUserId(), caption: caption, time: time, photo: photo, restaurant: restaurant, topics: topics)
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
    func getComments(_ postId: String) -> [Comment] {
        return comments.filter { $0.getParentId() == postId }
    }
    func postComment(_ comment: Comment) -> Comment {
        comments.append(comment)
        if let post = getPost(comment.getParentId()) {
            post.incrementCommentsCount()
        }
        return comment
    }
    func getLikes(_ postId: String) -> [Like] {
        return likes.filter { $0.getPostId() == postId }
    }
    func postLike(_ like: Like) -> Like {
        likes.append(like)
        if let post = getPost(like.getPostId()) {
            post.incrementLikesCount()
        }
        return like
    }
    func deleteLike(_ like: Like) -> Bool {
        for i in 0...(likes.count-1) {
            if likes[i].getPostId() == like.getPostId() && likes[i].getUserId() == like.getUserId() {
                likes.remove(at: i)
                if let post = getPost(like.getPostId()) {
                    post.decrementLikesCount()
                }
                return true
            }
        }
        return false
    }
}
