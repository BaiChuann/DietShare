//
//  Post.swift
//  DietShare
//
//  Created by BaiChuan on 24/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//
import UIKit
/**
 * overview
 * This class is an abstract datatype that represent a published post.
 * This class is mutable.
 */
/**
 * specification fields
 * postId: String -- represent the identifier of the post. postId is composed from userId and post time.
 * userId: String -- represent the user who creates this post. the ID must be a exisiting userId in database.
 * caption: String -- represent the caption of the post.
 * time: Date -- represent the data and time on which the comment is created.
 * photo: UIImage -- represent the photo that the user published.
 * restaurant: String? -- represent the restaurant identifier. Only present if user has chosed a restaurant when they created the post.
 * topics: [String]? -- represent thee topics identifiers. Only present if user has chosed any topics when they created the post. max size is 3.
 * commentsCount: Int -- represent the number of comments on this post.
 * likesCount: Int -- represent the number of likes on this post.
 **/
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
