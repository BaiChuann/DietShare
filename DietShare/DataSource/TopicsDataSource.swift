//
//  TopicsDataSource.swift
//  DietShare
//
//  Created by Shuang Yang on 28/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import BTree

protocol TopicsDataSource {
    associatedtype T: ReadOnlyTopic
    func getTopics() -> SortedSet<T>
    func addTopic(_ newTopic: Topic)
    func deleteTopic(_ newTopic: Topic)
    func updateTopic(_ oldTopic: Topic, _ newTopic: Topic)
    func syncTopics(_ newTopics: SortedSet<Topic>)
}
