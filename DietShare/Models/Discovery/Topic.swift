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
    private var followers: IDList
    private var posts: IDList
    private var popularity: Int {
        get{
            return self.posts.getListAsArray().count
        }
    }
    
    init(_ id: String, _ name: String, _ image: UIImage, _ description: String, _ followers: IDList, _ posts: IDList) {
        self.id = id
        self.name = name
        self.image = image
        self.description = description
        self.followers = followers
        self.posts = posts
    }
    
    convenience init() {
        self.init("", "", UIImage(), "", IDList(IDType.User), IDList(IDType.Post))
    }
    
    convenience init<T: ReadOnlyTopic> (_ readOnlyTopic: T) {
        self.init(readOnlyTopic.getID(), readOnlyTopic.getName(), readOnlyTopic.getImage(), readOnlyTopic.getDescription(), readOnlyTopic.getFollowersID(), readOnlyTopic.getPostsID())
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
    func getFollowersID() -> IDList {
        return self.followers
    }
    func getPopularity() -> Int {
        return self.popularity
    }
    
    func addPost(_ newPost: Post) {
        self.posts.addEntry(newPost.getPostId())
    }
    
    func addFollower(_ newFollower: User) {
        self.followers.addEntry(newFollower.getUserId())
        print("Follower added: \(newFollower.getUserId())")
    }
    
    func removeFollower(_ follower: User) {
        let oldList = self.followers.getListAsSet()
        self.followers.setList(oldList.filter {$0 != follower.getUserId()})
        print("Follower removed: \(follower.getUserId())")
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
                && lhs.followers == rhs.followers
    }
    
}
