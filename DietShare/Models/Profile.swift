//
//  Profile.swift
//  DietShare
//
//  Created by BaiChuan on 24/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//
import UIKit

class Profile {
    private var userId: String
    private var country: String
    private var description: String
    private var followings: [String]
    private var followers: [String]
    private var topics: [String]
    init(userId: String) {
        self.userId = userId
        self.country = ""
        self.description = ""
        self.followings = []
        self.followers = []
        self.topics = []
    }
    func getUserId() -> String {
        return userId
    }
    func getCountry() -> String {
        return country
    }
    func setCountry(_ country: String) {
        self.country = country
    }
    func getDescription() -> String {
        return description
    }
    func setDescription(_ description: String) {
        self.description = description
    }
    func getFollowings() -> [String] {
        return followings
    }
    func addFollowing(_ userId: String) {
        followings.append(userId)
    }
    func deleteFollowing(_ userId: String) {
        guard let removedIndex = followings.index(of: userId) else {
            return
        }
        followings.remove(at: removedIndex)
    }
    func getFollowers() -> [String] {
        return followers
    }
    func addFollower(_ userId: String) {
        followers.append(userId)
    }
    func deleteFollower(_ userId: String) {
        guard let removedIndex = followers.index(of: userId) else {
            return
        }
        followers.remove(at: removedIndex)
    }
    func getTopics() -> [String] {
        return topics
    }
    func addTopic(_ topicId: String) {
        topics.append(topicId)
    }
    func deleteTopic(_ topicId: String) {
        guard let removedIndex = topics.index(of: topicId) else {
            return
        }
        topics.remove(at: removedIndex)
    }
    
}
