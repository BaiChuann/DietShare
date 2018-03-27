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
    
    init(_ topics: SortedSet<T>) {
        self.topics = topics
    }
    
    convenience init() {
        let topics = SortedSet<T>()
        self.init(topics)
    }
    
    func getFullTopicList() -> [T] {
        var topicList = [T]()
        topicList.append(contentsOf: self.topics)
        return topicList
    }
    
    func getDisplayedList() -> [T] {
        var displayedList = [T]()
        var count = 0
        for topic in self.topics {
            if (count >= Constants.DiscoveryPage.numOfDisplayedTopics) {
                break
            }
            displayedList.append(topic)
            count += 1
        }
        return displayedList
    }
    
}
