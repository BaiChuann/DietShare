//
//  TopicsLocalDataSource.swift
//  DietShare
//
//  Created by Shuang Yang on 28/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import BTree
import SQLite

class TopicsLocalDataSource: TopicsDataSource {
    
    typealias T = Topic
    
    
    
    func getTopics() -> SortedSet<Topic> {
        <#code#>
    }
    
    func addTopic(_ newTopic: Topic) {
        <#code#>
    }
    
    func deleteTopic(_ newTopic: Topic) {
        <#code#>
    }
    
    func updateTopic(_ oldTopic: Topic, _ newTopic: Topic) {
        <#code#>
    }
    
    func syncTopics(_ newTopics: SortedSet<Topic>) {
        <#code#>
    }
    
    
    
    
}
