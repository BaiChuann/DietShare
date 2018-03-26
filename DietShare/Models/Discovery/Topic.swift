//
//  Topic.swift
//  DietShare
//
//  Created by Shuang Yang on 26/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation

/**
 * A Topic is a tag to user posts, much like a hashtag in Twitter, that connects all posts with the same tag so
 * that they can be displayed within the same page. Active users who posted on this topic will also be referenced.
 */
class Topic: ReadOnlyTopic {
    private let id: String
    private let name: String
    private var activeUsers: [String]
    private var posts: [String]
    private var popularity: Int {
        get{
            return self.posts.count
        }
    }
    
    init(_ id: String, _ name: String) {
        self.id = id
        self.name = name
        activeUsers = [String]()
        posts = [String]()
    }
    
    func getID() -> String {
        return self.id
    }
    func getName() -> String {
        return self.name
    }
    func getPostsID() -> [String] {
        return self.posts
    }
    func getActiveUsersID() -> [String] {
        return self.activeUsers
    }
    func getPopularity() -> Int {
        return self.popularity
    }
    
}
