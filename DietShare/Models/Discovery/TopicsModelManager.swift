//
//  TopicsModelManager.swift
//  DietShare
//
//  Created by Shuang Yang on 27/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//
// swiftlint:disable force_cast

import Foundation
import BTree

/**
 * A TopicsModelManager contains all the topic-related model objects and act as a facade to other objects using
 * these models.
 */
class TopicsModelManager {
    private var topicsDataSource: TopicsDataSource
    private var topics: [ReadOnlyTopic] {
        return topicsDataSource.getAllTopics().sorted(by: {$0.getPopularity() > $1.getPopularity()})
    }
    
    private init() {
        self.topicsDataSource = TopicsLocalDataSource.shared
    }
    
    //TODO - try use singleton here
    static let shared = TopicsModelManager()
    
    // Obtain a list of topics to be displayed in Discover Page
    func getShortList(_ numOfItem: Int) -> [ReadOnlyTopic] {
        var displayedList = [ReadOnlyTopic]()
        if topics.count < numOfItem {
            return topics
        }
        for i in 0..<numOfItem {
            displayedList.append(topics[i])
        }
        return displayedList
    }
    
    func getAllTopics() -> [ReadOnlyTopic] {
        return self.topics
    }
    
    func getTopics(_ index: Int, _ length: Int) -> [ReadOnlyTopic] {
        var topicsList = [ReadOnlyTopic]()
        if index > self.getNumOfTopics() || index + length > self.getNumOfTopics() {
            return topicsList
        }
        topicsList.append(contentsOf: self.topics)
        var returnList = [ReadOnlyTopic]()
        for i in 0..<length {
            returnList.append(topicsList[index + i])
        }
        return returnList
    }
    
    func getTopicFromID(_ ID: String) -> Topic? {
        return self.topicsDataSource.getTopicFromID(ID)
    }
    
    func getNumOfTopics() -> Int {
        return self.topicsDataSource.getNumOfTopics()
    }
    
    func addTopic(_ newTopic: Topic) {
        self.topicsDataSource.addTopic(newTopic)
    }
    
    func deleteTopic(_ topic: Topic) {
        self.topicsDataSource.deleteTopic(topic.getID())
    }
    
    // Add a new post under a topic, and update the database
    func addNewPost(_ newPost: Post, _ topic: Topic) {
        topic.addPost(newPost)
        self.topicsDataSource.updateTopic(topic.getID(), topic)
    }
    
    // Add a new follower to a topic, and update the database
    func addNewFollower(_ newFollower: User, _ topic: Topic) {
        topic.addFollower(newFollower)
        self.topicsDataSource.updateTopic(topic.getID(), topic)
    }
    
    func removeFollower(_ follower: User, _ topic: Topic) {
        topic.removeFollower(follower)
        self.topicsDataSource.updateTopic(topic.getID(), topic)
    }
}
