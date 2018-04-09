//
//  TopicsModelManager.swift
//  DietShare
//
//  Created by Shuang Yang on 27/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import BTree

/**
 * A TopicsModelManager contains all the topic-related model objects and act as a facade to other objects using
 * these models.
 */
class TopicsModelManager<T: ReadOnlyTopic> {
    private var topics:SortedSet<T>
    private var topicsDataSource: TopicsDataSource
    
    init() {
        self.topicsDataSource = TopicsLocalDataSource.shared
        self.topics = topicsDataSource.getTopics() as! SortedSet<T>
    }
    
    //TODO - try use singleton here
    
    func getFullTopicList() -> [T] {
        var topicList = [T]()
        topicList.append(contentsOf: self.topics)
        return topicList
    }
    
    // Obtain a list of topics to be displayed in Discover Page
    func getDisplayedList(_ numOfItem: Int) -> [T] {
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
    
    func getNumOfTopics() -> Int {
        return self.topicsDataSource.getNumOfTopics()
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
