//
//  TopicsDataSource.swift
//  DietShare
//
//  Created by Shuang Yang on 28/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import BTree

/**
 * A protocol for a data source for topics only. 
 * Implementations should guarantee: details are present and not null, field values are validated.
 */
protocol TopicsDataSource {
    
    func getAllTopics() -> SortedSet<Topic>
    func getNumOfTopics() -> Int
    func addTopic(_ newTopic: Topic)
    func addTopics(_ newTopics: SortedSet<Topic>)
    func deleteTopic(_ newTopicID: String)
    func updateTopic(_ oldTopicID: String, _ newTopic: Topic)
    func searchWithKeyword(_ keyword: String) -> [Topic]
}
