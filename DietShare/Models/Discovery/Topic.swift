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
    private var name: String
    private let imagePath: String
    private let description: String
    private var followers: StringList
    private var posts: StringList
    
    // TODO - active user logic -> to be added when PostModelManager is available
    private var activeUsers: StringList
    private var popularity: Int {
        get {
            return self.posts.getListAsArray().count
        }
    }
    
    init(_ id: String, _ name: String, _ imagePath: String, _ description: String, _ followers: StringList, _ posts: StringList, _ activeUsers: StringList) {
        self.id = id
        self.name = name
        self.imagePath = imagePath
        self.description = description
        self.followers = followers
        self.posts = posts
        self.activeUsers = activeUsers
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
        return self.popularity
    }
    
    func addPost(_ newPost: Post) {
        self.posts.addEntry(newPost.getPostId())
    }
    
    func addFollower(_ newFollower: User) {
        self.followers.addEntry(newFollower.getUserId())
        print("user \(newFollower.getUserId()) just followed topic: \(id)! ")
    }
    
    func removeFollower(_ follower: User) {
        let oldList = self.followers.getListAsSet()
        self.followers.setList(oldList.filter { $0 != follower.getUserId() })
        print("user \(follower.getUserId()) just unfollowed topic: \(id)! ")
        
    }
    
    // A topic is "<" than another one if it is higher in terms of popularity
    static func <(lhs: Topic, rhs: Topic) -> Bool {
        return lhs.popularity > rhs.popularity
    }
    
    static func ==(lhs: Topic, rhs: Topic) -> Bool {
        return lhs.id == rhs.id
                && lhs.name == rhs.name
                && lhs.popularity == rhs.popularity
                && lhs.posts == rhs.posts
                && lhs.followers == rhs.followers
    }
}
