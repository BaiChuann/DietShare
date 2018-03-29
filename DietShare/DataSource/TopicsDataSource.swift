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
    
    func getTopics() -> SortedSet<Topic>
    func addTopic(_ newTopic: Topic)
    func addTopics(_ newTopics: SortedSet<Topic>)
    func deleteTopic(_ newTopic: Topic)
    func updateTopic(_ oldTopic: Topic, _ newTopic: Topic)
}
