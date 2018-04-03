//
//  Topic.swift
//  DietShare
//
//  Created by Shuang Yang on 26/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

/**
 * A Topic is a tag to user posts, much like a hashtag in Twitter, that connects all posts with the same tag so
 * that they can be displayed within the same page. Active users who posted on this topic will also be referenced.
 */
class Topic: ReadOnlyTopic {
    
    private let id: String
    private let name: String
    private let image: UIImage
    private let description: String
    private var activeUsers: IDList
    private var posts: IDList
    private var popularity: Int {
        get{
            return self.posts.getList().count
        }
    }
    
    init(_ id: String, _ name: String, _ image: UIImage, _ description: String, _ activeUsers: IDList, _ posts: IDList) {
        self.id = id
        self.name = name
        self.image = image
        self.description = description
        self.activeUsers = activeUsers
        self.posts = posts
    }
    
    convenience init() {
        self.init("", "", UIImage(), "", IDList(IDType.User), IDList(IDType.Post))
    }
    
    convenience init<T: ReadOnlyTopic> (_ readOnlyTopic: T) {
        self.init(readOnlyTopic.getID(), readOnlyTopic.getName(), readOnlyTopic.getImage(), readOnlyTopic.getDescription(), readOnlyTopic.getActiveUsersID(), readOnlyTopic.getPostsID())
    }
    
    func getID() -> String {
        return self.id
    }
    func getName() -> String {
        return self.name
    }
    func getDescription() -> String {
        return self.description
    }
    func getImage() -> UIImage {
        return self.image
    }
    func getPostsID() -> IDList {
        return self.posts
    }
    func getActiveUsersID() -> IDList {
        return self.activeUsers
    }
    func getPopularity() -> Int {
        return self.popularity
    }
    
    func addPost(_ newPost: Post) {
        self.posts.addEntry(newPost.getPostId())
    }
    
    // A topic is "<" than another one if it is lower in terms of popularity
    static func <(lhs: Topic, rhs: Topic) -> Bool {
        return lhs.popularity < rhs.popularity
    }
    
    static func ==(lhs: Topic, rhs: Topic) -> Bool {
        return lhs.id == rhs.id
                && lhs.name == rhs.name
                && lhs.popularity == rhs.popularity
                && lhs.posts == rhs.posts
                && lhs.activeUsers == rhs.activeUsers
    }
    
}
