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
class TopicsModelManager<T: ReadOnlyTopic> {
    private var topicsDataSource: TopicsDataSource
    private var topics: SortedSet<T> {
        return topicsDataSource.getAllTopics() as! SortedSet<T>
    }
    
    init() {
        self.topicsDataSource = TopicsLocalDataSource.shared
    }
    
    //TODO - try use singleton here
    
    // Obtain a list of topics to be displayed in Discover Page
    func getShortListForDisplay(_ numOfItem: Int) -> [T] {
        var displayedList = [T]()
        var count = 0
        for topic in self.topics {
            if (count >= numOfItem) {
                break
            }
            displayedList.append(topic)
            count += 1
        }
        return displayedList
    }
    
    func getAllTopics() -> [T] {
        var topicsList = [T]()
        topicsList.append(contentsOf: self.topics)
        return topicsList
    }
    
    func getTopics(_ index: Int, _ length: Int) -> [T] {
        var topicsList = [T]()
        if index > self.getNumOfTopics() || index + length > self.getNumOfTopics() {
            return topicsList
        }
        topicsList.append(contentsOf: self.topics)
        var returnList = [T]()
        for i in 0..<length {
            returnList.append(topicsList[index + i])
        }
        return returnList
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
}
