//  Like.swift
//  DietShare
//
//  Created by BaiChuan on 24/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//
import UIKit

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
