//
//  TopicsLocalDataSourceTest.swift
//  DietShareTests
//
//  Created by Shuang Yang on 10/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import XCTest
@testable import DietShare

class TopicsLocalDataSourceTest: XCTestCase {
    
    private final var testDataSource: TopicsLocalDataSource?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testGetTopics() {
        var topics = [Topic]()
        let testDataSource0 = TopicsLocalDataSource.getTestInstance(topics, "test0")
        XCTAssert(testDataSource0.getAllTopics().count == topics.count, "Incorrect list of topics obtained")
        XCTAssert(testDataSource0.getNumOfTopics() == 0, "Incorrect number of topics obtained")
        XCTAssert(testDataSource0.getTopicFromID("1") == nil, "Incorrect topic obtained")
        
        let topic1 = Topic("1", "test1")
        topics.append(topic1)
        let testDataSource1 = TopicsLocalDataSource.getTestInstance(topics)
        XCTAssert(testDataSource1.getAllTopics().count == topics.count, "Incorrect list of topics obtained")
        XCTAssert(testDataSource1.getNumOfTopics() == 1, "Incorrect number of topics obtained")
        XCTAssert(testDataSource1.getTopicFromID("1")! == topic1, "Incorrect topic obtained")
        
        let topic2 = Topic("2", "test2")
        topics.append(topic2)
        let testDataSource2 = TopicsLocalDataSource.getTestInstance(topics)
        XCTAssert(testDataSource2.getAllTopics().count == topics.count, "Incorrect list of topics obtained")
        XCTAssert(testDataSource2.getNumOfTopics() == 2, "Incorrect number of topics obtained")
        XCTAssert(testDataSource2.getTopicFromID("2")! == topic2, "Incorrect topic obtained")
        
        testDataSource0.removeDB(Constants.Tables.topics + "test0")
        testDataSource1.removeDB(Constants.Tables.topics + "test1")
        testDataSource2.removeDB(Constants.Tables.topics + "test2")
    }
    
    func testAddTopic() {
        var topics = [Topic]()
        let testDataSource0 = TopicsLocalDataSource.getTestInstance(topics, "test0")
        XCTAssert(testDataSource0.getNumOfTopics() == 0, "Incorrect number of topics obtained")
        // Add topic
        let topic1 = Topic("1", "test1")
        testDataSource0.addTopic(topic1)
        XCTAssert(testDataSource0.getNumOfTopics() == 1, "Incorrect number of topics obtained")
        XCTAssert(testDataSource0.getTopicFromID("1")! == topic1, "Incorrect topic obtained")
        XCTAssert(testDataSource0.containsTopic(topic1.getID()), "Incorrect topic obtained")
        
        // Add duplicate topic
        testDataSource0.addTopic(topic1)
        XCTAssert(testDataSource0.getNumOfTopics() == 1, "Incorrect number of topics obtained")
        XCTAssert(testDataSource0.getTopicFromID("1")! == topic1, "Incorrect topic obtained")
        XCTAssert(testDataSource0.containsTopic(topic1.getID()), "Incorrect topic obtained")
        
        // Add multiple topics
        let topic2 = Topic("2", "test2")
        let topic3 = Topic("3", "test3")
        topics.append(topic2)
        topics.append(topic3)
        testDataSource0.addTopics(topics)
        XCTAssert(testDataSource0.getNumOfTopics() == 3, "Incorrect number of topics obtained")
        XCTAssert(testDataSource0.getTopicFromID("1")! == topic1, "Incorrect topic obtained")
        XCTAssert(testDataSource0.getTopicFromID("2")! == topic2, "Incorrect topic obtained")
        XCTAssert(testDataSource0.getTopicFromID("3")! == topic3, "Incorrect topic obtained")
        XCTAssert(testDataSource0.containsTopic(topic1.getID()), "Incorrect topic obtained")
        XCTAssert(testDataSource0.containsTopic(topic2.getID()), "Incorrect topic obtained")
        XCTAssert(testDataSource0.containsTopic(topic3.getID()), "Incorrect topic obtained")
        
        testDataSource0.removeDB(Constants.Tables.topics + "test0")
    }
    
    func testDeleteTopic() {
        let topics = [Topic]()
        let testDataSource0 = TopicsLocalDataSource.getTestInstance(topics, "test0")
        XCTAssert(testDataSource0.getNumOfTopics() == 0, "Incorrect number of topics obtained")
        
        let topic1 = Topic("1", "test1")
        testDataSource0.addTopic(topic1)
        XCTAssert(testDataSource0.getNumOfTopics() == 1, "Incorrect number of topics obtained")
        XCTAssert(testDataSource0.containsTopic(topic1.getID()), "Incorrect topic obtained")
        
        testDataSource0.deleteTopic(topic1.getID())
        XCTAssert(testDataSource0.getNumOfTopics() == 0, "Incorrect number of topics obtained")
        XCTAssert(!testDataSource0.containsTopic(topic1.getID()), "Incorrect topic obtained")
        
        testDataSource0.removeDB(Constants.Tables.topics + "test0")
    }
    
    func testUpdateTopic() {
        let topics = [Topic]()
        let testDataSource0 = TopicsLocalDataSource.getTestInstance(topics, "test0")
        XCTAssert(testDataSource0.getNumOfTopics() == 0, "Incorrect number of topics obtained")
        
        let topic1 = Topic("1", "test1")
        testDataSource0.addTopic(topic1)
        XCTAssert(testDataSource0.getNumOfTopics() == 1, "Incorrect number of topics obtained")
        
        topic1.setName("test1.1")
        testDataSource0.updateTopic(topic1.getID(), topic1)
        XCTAssert(testDataSource0.getNumOfTopics() == 1, "Incorrect number of topics obtained")
        XCTAssert(testDataSource0.containsTopic(topic1.getID()), "Incorrect topic obtained")
        XCTAssert(testDataSource0.getTopicFromID(topic1.getID())?.getName() == topic1.getName(), "Incorrect topic obtained")
        
        testDataSource0.removeDB(Constants.Tables.topics + "test0")
    }
    
    func testSearchByKeyword() {
        let topicWithKeyword = Topic("withKeyword", Constants.Test.withKeyword)
        let topicWithoutKeyword = Topic("WithoutKeyword", Constants.Test.withoutKeyword)
        
        var topics = [topicWithKeyword, topicWithoutKeyword]
        testDataSource = TopicsLocalDataSource.getTestInstance(topics)
        if let searchResult = testDataSource?.searchWithKeyword(Constants.Test.keyword) {
            XCTAssert(searchResult.count == 1, "Incorrect number of search result")
            XCTAssert(searchResult[0] == topicWithKeyword, "Incorrect search result")
        }

        let topicWithEmpty = Topic(" ", " ")
        topics.append(topicWithEmpty)
        testDataSource = TopicsLocalDataSource.getTestInstance(topics)
        if let searchResult = testDataSource?.searchWithKeyword(Constants.Test.keyword) {
            XCTAssert(searchResult.count == 1, "Incorrect number of search result")
            XCTAssert(searchResult[0] == topicWithKeyword, "Incorrect search result")
        }

        let posts = StringList(.Post, ["Post"])
        let topicWithKeyword2 = Topic("withKeyword2", Constants.Test.withKeyword + "2", posts)
        topics.append(topicWithKeyword2)
        testDataSource = TopicsLocalDataSource.getTestInstance(topics)
        if let searchResult = testDataSource?.searchWithKeyword(Constants.Test.keyword) {
            XCTAssert(searchResult.count == 2, "Incorrect number of search result")
            XCTAssert(searchResult[0] == topicWithKeyword2, "Topics are not ranked in the correct descending order of popularity")
            XCTAssert(searchResult[1] == topicWithKeyword, "Topics are not ranked in the correct descending order of popularity")
        }
    }
    
}

extension Topic {
    convenience init(_ id: String, _ name: String) {
        self.init(id, name, "vegi-life", " ", StringList(.User), StringList(.Post))
    }
    
    convenience init(_ id: String, _ name: String, _ posts: StringList) {
        self.init(id, name, "vegi-life", " ", StringList(.User), posts)
    }
}
