//  Like.swift
//  DietShare
//
//  Created by BaiChuan on 24/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//
import UIKit
/**
 * overview
 * This class is an abstract datatype that represent a like of a published post.
 * This class is immutable.
 */
/**
 * specification fields
 * userId: String -- represent the user who makes this like action. the ID must be a exisiting userId in database.
 * postId: String -- represent the identifier of the post that this like belongs to. the ID must be a exisiting postId in database.
 * time: Date -- represent the data and time on which the like is created.
 **/
class Like {
    private var userId: String
    private var postId: String
    private var time: Date
    init(userId: String, postId: String, time: Date) {
        self.userId = userId
        self.postId = postId
        self.time = time
    }
    func getUserId() -> String {
        return userId
    }
    func getPostId() -> String {
        return postId
    }
    func getTime() -> Date {
        return time
    }
}
