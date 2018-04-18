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
        prepopulate()
//        for i in 1...20 {
//            let newPost = Post(userId: "1", caption: "today I ate this thing it was super niceeeeee", time: Date(), photo: UIImage(named: "post-example")!, restaurant: "1", topics: ["1", "2", "3", "4", "5"])
//            posts.append(newPost)
//        }
//        for i in 2...10 {
//            let newPost = Post(userId: String(i), caption: "today I ate this thing it was super niceeeeee", time: Date(), photo: UIImage(named: "post-example")!, restaurant: "1", topics: ["1", "2", "3", "4", "5"])
//            posts.append(newPost)
//        }
//        let postId = posts[0].getPostId()
//        let newComment = Comment(userId: "3", parentId: postId, content: "This looks so nice", time: Date())
//        for _ in 1...10 {
//             comments.append(newComment)
//        }
//        let newLike = Like(userId: "3", postId: postId, time: Date())
//        for _ in 1...10 {
//            likes.append(newLike)
//        }
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
        var followingUsers = profileManager.getFollowingUsers(currentUser.getUserId())
        followingUsers.append(currentUser.getUserId())
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
        var results = [Post]()
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
    private func prepopulate() {
        
        /*for i in 1...20 {
         let newPost = Post(userId: String(i), caption: "today I ate this thing it was super niceeeeee", time: Date(), photo: UIImage(named: "post-example")!, restaurant: "koufu", topics: ["1", "2", "3", "4", "5"])
         addPost(newPost)
         }*/
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let newPost1 = Post(userId: "6", caption: "Today is a cheat-day. Had a lot of fat and protein.", time: dateFormatterGet.date(from: "2017-10-19 10:10:13")!, photo: UIImage(named: "topic1-1")!, restaurant: "12", topics: ["1"])
        let newPost2 = Post(userId: "9", caption: "Yum yum. A big breakfast #healthy breakfast", time: dateFormatterGet.date(from: "2018-01-05 08:04:15")!, photo: UIImage(named: "topic1-2")!, restaurant: nil, topics: ["1"])
        let newPost3 = Post(userId: "9", caption: "My 5-year-old daughter really love this dish", time: dateFormatterGet.date(from: "2016-11-30 09:39:27")!, photo: UIImage(named: "topic1-3")!, restaurant: "13", topics: ["1", "3"])
        let newPost4 = Post(userId: "4", caption: "A really tasty salad made by myself.", time: dateFormatterGet.date(from: "2018-02-14 12:18:26")!, photo: UIImage(named: "topic1-4")!, restaurant: "13", topics: ["1", "7"])
        let newPost5 = Post(userId: "3", caption: "This caesar salad is really food and balanced. Made my day!", time: dateFormatterGet.date(from: "2017-08-30 12:24:26")!, photo: UIImage(named: "topic1-5")!, restaurant: "19", topics: ["1"])
        let newPost6 = Post(userId: "7", caption: "Day 36 in diet eating plan", time: dateFormatterGet.date(from: "2018-04-18 16:09:46")!, photo: UIImage(named: "topic1-6")!, restaurant: nil, topics: ["1"])
        let newPost7 = Post(userId: "10", caption: "Try to have a vegetarian breakfast", time: dateFormatterGet.date(from: "2017-10-10 17:29:53")!, photo: UIImage(named: "topic1-7")!, restaurant: "5", topics: ["1", "9"])
        let newPost8 = Post(userId: "9", caption: "Made a fish dish for my son. Omega 3 is good for his body", time: dateFormatterGet.date(from: "2018-01-01 07:35:37")!, photo: UIImage(named: "topic2-1")!, restaurant: nil, topics: ["2", "3"])
        let newPost9 = Post(userId: "1", caption: "First time using collage feature of this App. Varieties of pictures suit my food", time: dateFormatterGet.date(from: "2016-02-29 12:24:26")!, photo: UIImage(named: "topic3-1")!, restaurant: "3", topics: ["3"])
        let newPost11 = Post(userId: "4", caption: "OMG!!!! I will be 2kg heavier tmr!!! #1834CalPizza", time: dateFormatterGet.date(from: "2017-04-23 09:37:58")!, photo: UIImage(named: "topic3-2")!, restaurant: "1", topics: ["3"])
        let newPost12 = Post(userId: "10", caption: "Where’s my yogurt? LOL", time: dateFormatterGet.date(from: "2016-11-06 13:45:39")!, photo: UIImage(named: "topic4-1")!, restaurant: nil, topics: ["4"])
        let newPost13 = Post(userId: "3", caption: "I am growing fat! I saw myself when I saw this sticker.", time: dateFormatterGet.date(from: "2018-03-02 23:59:35")!, photo: UIImage(named: "topic4-2")!, restaurant: nil, topics: ["4"])
        let newPost14 = Post(userId: "2", caption: "22g protein in 25g food. Btw, I am so surprised that this food can be recognized!", time: dateFormatterGet.date(from: "2018-03-29 12:15:18")!, photo: UIImage(named: "topic4-3")!, restaurant: "7", topics: ["4", "6"])
        let newPost15 = Post(userId: "5", caption: "I DON’T LIKE SALAD. My wife forced me to eat it. #HealthyFoodSucks", time: dateFormatterGet.date(from: "2017-07-15 08:00:18")!, photo: UIImage(named: "topic5-1")!, restaurant: "25", topics: ["5"])
        let newPost16 = Post(userId: "8", caption: "Tomatoes and olive oil. Should let my husband eat healthy food. He had high blood pressure, but he just like carrot cake.", time: dateFormatterGet.date(from: "2017-06-30 17:02:05")!, photo: UIImage(named: "topic5-2")!, restaurant: "1", topics: ["5"])
        let newPost17 = Post(userId: "5", caption: "Meh. Maybe I just like unhealthy food. Much better than the salad my wife gave me. What’s the point having food tastes like nothing?", time: dateFormatterGet.date(from: "2017-04-30 14:23:27")!, photo: UIImage(named: "topic5-3")!, restaurant: "2", topics: ["5"])
        let newPost18 = Post(userId: "6", caption: "Delicious and high in protein. My trainer’s recommendation. #GymDay", time: dateFormatterGet.date(from: "2017-05-01 20:34:28")!, photo: UIImage(named: "topic6-1")!, restaurant: "15", topics: ["9"])
        let newPost19 = Post(userId: "4", caption: "Yangzhou Fried Rice! Looks as good as in the restaurant, right?", time: dateFormatterGet.date(from: "2017-07-21 22:21:34")!, photo: UIImage(named: "topic7-1")!, restaurant: nil, topics: ["7"])
        let newPost20 = Post(userId: "4", caption: "Today is my father-in-law’s 60th birthday. Need to prove myself.", time: dateFormatterGet.date(from: "2016-04-15 19:03:47")!, photo: UIImage(named: "topic7-2")!, restaurant: nil, topics: ["7"])
        let newPost21 = Post(userId: "2", caption: "Really easy to cook! Healthy and delicious!", time: dateFormatterGet.date(from: "2018-03-26 16:52:59")!, photo: UIImage(named: "topic7-3")!, restaurant: nil, topics: ["7"])
        let newPost22 = Post(userId: "3", caption: "I will NEVER try this! My dad cooked a whole pot of paste!!! He REALLY need to learn how to cook. I think it tastes like chicken", time: dateFormatterGet.date(from: "2017-12-03 13:14:15")!, photo: UIImage(named: "topic7-4")!, restaurant: nil, topics: ["3", "6", "7"])
        let newPost23 = Post(userId: "1", caption: "Unsaturated fat can protect your vessel and heart. I just can resist things with avocado #AvocadeAddict", time: dateFormatterGet.date(from: "2017-12-20 08:09:10")!, photo: UIImage(named: "topic8-1")!, restaurant: "1", topics: ["8"])
        let newPost24 = Post(userId: "9", caption: "Don’t be beguiled by its appearance. It tastes really goooood!!", time: dateFormatterGet.date(from: "2017-11-20 09:35:13")!, photo: UIImage(named: "topic8-2")!, restaurant: nil, topics: ["8"])
        let newPost25 = Post(userId: "7", caption: "Looks like leaves. Tastes like leaves. After eating a whole bowl of this, I feel I am a vegetable walking. Meh.", time: dateFormatterGet.date(from: "2018-01-19 18:34:10")!, photo: UIImage(named: "topic9-1")!, restaurant: "15", topics: ["5", "9"])
        let newPost26 = Post(userId: "10", caption: "Vegan food can be really palatable! Should let my family have vegan food once a week!", time: dateFormatterGet.date(from: "2017-1-11 20:54:00")!, photo: UIImage(named: "topic9-2")!, restaurant: "16", topics: ["9"])
        let newPost27 = Post(userId: "1", caption: "My grandma cooked my favorite biryani for me. I really missed this taste in the last exchange year in States! Americans should at least learn how to cook edible Asian food for Asians.", time: dateFormatterGet.date(from: "2017-02-14 11:57:04")!, photo: UIImage(named: "topic9-3")!, restaurant: nil, topics: ["7", "9"])
        addPost(newPost1)
        addPost(newPost2)
        addPost(newPost3)
        addPost(newPost4)
        addPost(newPost5)
        addPost(newPost6)
        addPost(newPost7)
        addPost(newPost8)
        addPost(newPost9)
        //addPost(newPost10)
        addPost(newPost11)
        addPost(newPost12)
        addPost(newPost13)
        addPost(newPost14)
        addPost(newPost15)
        addPost(newPost16)
        addPost(newPost17)
        addPost(newPost18)
        addPost(newPost19)
        addPost(newPost20)
        addPost(newPost21)
        addPost(newPost22)
        addPost(newPost23)
        addPost(newPost24)
        addPost(newPost25)
        addPost(newPost26)
        addPost(newPost27)
        let newComment1 = Comment(userId: "2", parentId: posts[5].getPostId(), content: "This looks so nice", time: dateFormatterGet.date(from: "2018-04-18 17:09:46")!)
        let newComment2 = Comment(userId: "3", parentId: posts[5].getPostId(), content: "Wow you really did it sia", time: dateFormatterGet.date(from: "2018-04-18 17:54:13")!)
        let newComment3 = Comment(userId: "4", parentId: posts[5].getPostId(), content: "eh I wish I could do that also hahaha", time: dateFormatterGet.date(from: "2018-04-18 19:29:36")!)
        let newComment4 = Comment(userId: "5", parentId: posts[5].getPostId(), content: "the level of effort.", time: dateFormatterGet.date(from: "2018-04-18 20:33:12")!)
        let newComment5 = Comment(userId: "6", parentId: posts[1].getPostId(), content: "I want alsoooooo", time: dateFormatterGet.date(from: "2018-04-18 17:09:46")!)
        let newComment6 = Comment(userId: "7", parentId: posts[1].getPostId(), content: "Omg that's my dream breakfast teach me pleaseeee", time: dateFormatterGet.date(from: "2018-04-18 17:54:13")!)
        let newComment7 = Comment(userId: "8", parentId: posts[1].getPostId(), content: "cute", time: dateFormatterGet.date(from: "2018-04-18 19:29:36")!)
        let newComment8 = Comment(userId: "2", parentId: posts[1].getPostId(), content: "bo jio", time: dateFormatterGet.date(from: "2018-04-18 20:33:12")!)
        let newComment9 = Comment(userId: "3", parentId: posts[12].getPostId(), content: "I didn't know you so healthy one", time: dateFormatterGet.date(from: "2018-04-18 17:09:46")!)
        let newComment10 = Comment(userId: "7", parentId: posts[12].getPostId(), content: "Steady :)", time: dateFormatterGet.date(from: "2018-04-18 17:54:13")!)
        let newComment11 = Comment(userId: "9", parentId: posts[21].getPostId(), content: "a!v!o!c!a!d!o! YAS!", time: dateFormatterGet.date(from: "2018-04-18 19:29:36")!)
        let newComment12 = Comment(userId: "5", parentId: posts[21].getPostId(), content: "That's my favourite tooooooooooo", time: dateFormatterGet.date(from: "2018-04-18 20:33:12")!)
        comments.append(newComment1)
        posts[5].incrementCommentsCount()
        comments.append(newComment2)
        posts[5].incrementCommentsCount()
        comments.append(newComment3)
        posts[5].incrementCommentsCount()
        comments.append(newComment4)
        posts[5].incrementCommentsCount()
        comments.append(newComment5)
        posts[1].incrementCommentsCount()
        comments.append(newComment6)
        posts[1].incrementCommentsCount()
        comments.append(newComment7)
        posts[1].incrementCommentsCount()
        comments.append(newComment8)
        posts[1].incrementCommentsCount()
        comments.append(newComment9)
        posts[12].incrementCommentsCount()
        comments.append(newComment10)
        posts[12].incrementCommentsCount()
        comments.append(newComment11)
        posts[21].incrementCommentsCount()
        comments.append(newComment12)
        posts[21].incrementCommentsCount()
        let newLike1 = Like(userId: "2", postId: posts[5].getPostId(), time: dateFormatterGet.date(from: "2018-04-18 17:09:46")!)
        let newLike2 = Like(userId: "3", postId: posts[5].getPostId(), time: dateFormatterGet.date(from: "2018-04-18 17:54:13")!)
        let newLike3 = Like(userId: "4", postId: posts[5].getPostId(), time: dateFormatterGet.date(from: "2018-04-18 19:29:36")!)
        let newLike4 = Like(userId: "5", postId: posts[5].getPostId(), time: dateFormatterGet.date(from: "2018-04-18 20:33:12")!)
        let newLike5 = Like(userId: "8", postId: posts[5].getPostId(), time: dateFormatterGet.date(from: "2018-04-18 21:39:36")!)
        let newLike6 = Like(userId: "9", postId: posts[5].getPostId(), time: dateFormatterGet.date(from: "2018-04-18 22:33:12")!)
        let newLike7 = Like(userId: "2", postId: posts[1].getPostId(), time: dateFormatterGet.date(from: "2018-04-18 17:09:46")!)
        let newLike8 = Like(userId: "3", postId: posts[1].getPostId(), time: dateFormatterGet.date(from: "2018-04-18 17:54:13")!)
        let newLike9 = Like(userId: "4", postId: posts[1].getPostId(), time: dateFormatterGet.date(from: "2018-04-18 19:29:36")!)
        let newLike10 = Like(userId: "5", postId: posts[1].getPostId(), time: dateFormatterGet.date(from: "2018-04-18 20:33:12")!)
        let newLike11 = Like(userId: "8", postId: posts[21].getPostId(), time: dateFormatterGet.date(from: "2018-04-18 21:39:36")!)
        let newLike12 = Like(userId: "9", postId: posts[21].getPostId(), time: dateFormatterGet.date(from: "2018-04-18 22:33:12")!)
        postLike(newLike1)
        postLike(newLike2)
        postLike(newLike3)
        postLike(newLike4)
        postLike(newLike5)
        postLike(newLike6)
        postLike(newLike7)
        postLike(newLike8)
        postLike(newLike9)
        postLike(newLike10)
        postLike(newLike11)
        postLike(newLike12)
    }
    func addPost(_ post: Post) {
        posts.append(post)
    }
}
