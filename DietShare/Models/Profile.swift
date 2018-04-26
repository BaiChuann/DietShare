//
//  Profile.swift
//  DietShare
//
//  Created by BaiChuan on 24/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//
import UIKit
/**
 * overview
 * This class is an abstract datatype that represent a profile of a user.
 * This class is mutable.
 */
/**
 * specification fields
 * userId: String -- represent the user who own this profile. the ID must be a exisiting userId in database.
 * country: String -- for future extension.
 * description: String -- represent the description that the user created.
 * followings: [String] -- the identifers of the users whom the profile owner currently follows. Each identifier in the list must exist in the database.
 * followers: [String] -- the identifers of the users who currently follow the profile owner. Each identifier in the list must exist in the database.
 * topics: [String] -- the identifers of the topics that the profile owner currently follows. Each identifier in the list must exist in the database.
 **/
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
