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
 * Overview:
 *
 * A Topic is a tag to user posts, much like a hashtag in Twitter, that connects all posts with the same tag so
 * that they can be displayed within the same page. Active users who posted on this topic will also be referenced.
 * It is mutable.
 *
 * Specification fields:
 *
 * - id: String - id of the topic
 * - name: String - name of the topic
 * - imagePath: String - file path of the image of the topic
 * - description: String - a brief description of the topic
 * - followers: StringList - a list of ids of the users who follow this topic
 * - posts: StringList - a list of ids of posts under this topic
 * - activeUsers: StringList - a list of ids of users who post frequently under this topic
 * - popularity: Int - number of posts under this topic, indicating its popularity
 */
class Topic: ReadOnlyTopic {
    
    private let id: String
    private var name: String
    private let imagePath: String
    private let description: String
    private var followers: StringList
    private var posts: StringList
    
    private var activeUsers: StringList
    private var popularity: Int {
        return self.posts.getListAsArray().count
    }
    
    init(_ id: String, _ name: String, _ imagePath: String, _ description: String, _ followers: StringList, _ posts: StringList, _ activeUsers: StringList) {
        self.id = id
        self.name = name
        self.imagePath = imagePath
        self.description = description
        self.followers = followers
        self.posts = posts
        self.activeUsers = activeUsers
//        print("Topic Post inited: \(name) has \(posts.getListAsArray().count) posts")
    }
    
    convenience init(_ id: String, _ name: String, _ imagePath: String, _ description: String, _ followers: StringList, _ posts: StringList) {
        self.init(id, name, imagePath, description, followers, posts, StringList(.User))
    }
    
    convenience init() {
        self.init("", "", "void-bg", "", StringList(ListType.User), StringList(ListType.Post), StringList(.User))
    }
    
    convenience init (_ readOnlyTopic: ReadOnlyTopic) {
        self.init(readOnlyTopic.getID(), readOnlyTopic.getName(), readOnlyTopic.getImagePath(), readOnlyTopic.getDescription(), readOnlyTopic.getFollowersID(), readOnlyTopic.getPostsID(), readOnlyTopic.getActiveUserID())
    }

    func getID() -> String {
        return self.id
    }
    func getName() -> String {
        return self.name
    }
    func setName(_ name: String) {
        self.name = name
    }
    func getDescription() -> String {
        return self.description
    }
    func getImageAsUIImage() -> UIImage {
        assert(UIImage(named: self.imagePath) != nil)
        
        if let uiImage = UIImage(named: self.imagePath) {
            return uiImage
        }
        return #imageLiteral(resourceName: "void-bg")
    }
    func getImagePath() -> String {
        return self.imagePath
    }
    func getPostsID() -> StringList {
        return self.posts
    }
    func getFollowersID() -> StringList {
        return self.followers
    }
    func getActiveUserID() -> StringList {
        return self.activeUsers
    }
    func getPopularity() -> Int {
        return self.posts.getListAsArray().count
    }
    
    func addPost(_ newPost: Post) {
        self.posts.addEntry(newPost.getPostId())
//        print("New Post added: topic \(self.getName())'s popularity: \(self.getPopularity())")
    }
    
    func addFollower(_ newFollower: User) {
        self.followers.addEntry(newFollower.getUserId())
    }
    
    func removeFollower(_ follower: User) {
        let oldList = self.followers.getListAsSet()
        self.followers.setList(oldList.filter { $0 != follower.getUserId() })
        print("user \(follower.getUserId()) just unfollowed topic: \(id)! ")
        
    }
    
    static func == (lhs: Topic, rhs: Topic) -> Bool {
        return lhs.id == rhs.id
                && lhs.name == rhs.name
                && lhs.popularity == rhs.popularity
                && lhs.posts == rhs.posts
                && lhs.followers == rhs.followers
    }
}
