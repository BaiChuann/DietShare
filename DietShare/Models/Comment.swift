//  Comment.swift
//  DietShare
//
//  Created by BaiChuan on 24/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//
import UIKit

class Comment {
    private var commentId: String
    private var userId: String
    private var parentId: String
    private var childrenIds: [String]
    private var content: String
    private var time: Date
    init(userId: String, parentId: String, content: String, time: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from:time)
        self.parentId = parentId
        self.userId = userId
        self.commentId = userId + parentId + dateString
        self.content = content
        self.time = time
        self.childrenIds = []
    }
    func getCommentId() -> String {
        return commentId
    }
    func getUserId() -> String {
        return userId
    }
    func getParentId() -> String {
        return parentId
    }
    func getChildrenIds() -> [String] {
        return childrenIds
    }
    func addChild(_ commentId: String) {
        childrenIds.append(commentId)
    }
    func deleteChild(_ commentId: String) {
        guard let removedIndex = childrenIds.index(of: commentId) else {
            return
        }
        childrenIds.remove(at: removedIndex)
    }
    func getContent() -> String {
        return content
    }
    func getTime() -> Date {
        return time
    }
}
