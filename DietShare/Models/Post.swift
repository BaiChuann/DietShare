//
//  Post.swift
//  DietShare
//
//  Created by BaiChuan on 24/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//
import UIKit

class Post {
    private var postId: String
    private var userId: String
    private var caption: String
    private var time: Date
    private var photo: UIImage
    private var restaurant: String?
    private var topics: [String]?
    private var commentsCount: Int
    private var likesCount: Int
    init(userId: String, caption: String, time: Date, photo: UIImage, restaurant: String?, topics: [String]?) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: time)
        self.postId = userId + dateString
        self.userId = userId
        self.caption = caption
        self.time = time
        self.photo = photo
        if restaurant != nil {
            self.restaurant = restaurant
        }
        if topics != nil {
            self.topics = topics
        }
        self.commentsCount = 0
        self.likesCount = 0
    }
    init(postId: String, userId: String, caption: String, time: Date, photo: UIImage, restaurant: String?, topics: [String]?) {
        self.postId = postId
        self.userId = userId
        self.caption = caption
        self.time = time
        self.photo = photo
        if restaurant != nil {
            self.restaurant = restaurant
        }
        if topics != nil {
            self.topics = topics
        }
        self.commentsCount = 0
        self.likesCount = 0
    }
    func getPostId() -> String {
        return postId
    }
    func setPostId(_ id: String) {
        postId = id
    }
    func getUserId() -> String {
        return userId
    }
    func getCaption() -> String {
        return caption
    }
    func getTime() -> Date {
        return time
    }
    func getPhoto() -> UIImage {
        return photo
    }
    func getRestaurant() -> String? {
        return restaurant
    }
    func getTopics() -> [String]? {
        return topics
    }
    func getCommentsCount() -> Int {
        return commentsCount
    }
    func incrementCommentsCount() {
        commentsCount += 1
    }
    func decrementCommentsCount() {
        commentsCount -= 1
    }
    func getLikesCount() -> Int {
        return likesCount
    }
    func incrementLikesCount() {
        likesCount += 1
    }
    func decrementLikesCount() {
        likesCount -= 1
    }
}
