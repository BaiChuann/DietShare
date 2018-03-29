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
        
        // Prepopulate the datasource - only for testing
        prepopulate()
    }
    
    func getFullTopicList() -> [T] {
        var topicList = [T]()
        topicList.append(contentsOf: self.topics)
        return topicList
    }
    
    // Obtain a list of topics to be displayed in Discover Page
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
    
    private func prepopulate() {
        for i in 0..<20 {
            let topic = Topic(String(i), "VegiLife", #imageLiteral(resourceName: "vegi-life"), "A little bit of Vegi goes a long way", IDList(.User), IDList(.Post))
            self.topicsDataSource.addTopic(topic)
        }
    }
    
}
