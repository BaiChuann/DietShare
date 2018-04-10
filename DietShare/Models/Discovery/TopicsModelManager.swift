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
    private var topicsDataSource: TopicsDataSource
    
    init() {
        self.topicsDataSource = TopicsLocalDataSource.shared
    }
    
    //TODO - try use singleton here
    
//    // Obtain a list of topics to be displayed in Discover Page
//    func getShortListForDisplay(_ numOfItem: Int) -> [T] {
//        var displayedList = [T]()
//        var count = 0
//        // TODO - Change to SQLite implementation
//        return displayedList
//    }
    
    func getTopics(_ index: Int, _ number: Int) -> [T] {
        return self.topicsDataSource.getTopics(index, number) as! [T]
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
