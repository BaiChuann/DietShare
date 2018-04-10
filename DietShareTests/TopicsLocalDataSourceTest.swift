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
    
    func testSearchByKeyword() {
        let topicWithKeyword = Topic("withKeyword", Constants.Test.withKeyword)
        let topicWithoutKeyword = Topic("WithoutKeyword", Constants.Test.withoutKeyword)
        
        var topics = [topicWithKeyword, topicWithoutKeyword]
        testDataSource = TopicsLocalDataSource.getTestInstance(topics)
        if let searchResult = testDataSource?.searchWithKeyword(Constants.Test.keyword) {
            XCTAssert(searchResult.count == 1)
            XCTAssert(searchResult[0] == topicWithKeyword)
        }
    
        let topicWithEmpty = Topic(" ", " ")
        topics.append(topicWithEmpty)
        testDataSource = TopicsLocalDataSource.getTestInstance(topics)
        if let searchResult = testDataSource?.searchWithKeyword(Constants.Test.keyword) {
            XCTAssert(searchResult.count == 1)
            XCTAssert(searchResult[0] == topicWithKeyword)
        }
        
        let posts = StringList(.Post, ["Post"])
        let topicWithKeyword2 = Topic("withKeyword2", Constants.Test.withKeyword + "2", posts)
        topics.append(topicWithKeyword2)
        testDataSource = TopicsLocalDataSource.getTestInstance(topics)
        if let searchResult = testDataSource?.searchWithKeyword(Constants.Test.keyword) {
            XCTAssert(searchResult.count == 2)
            XCTAssert(searchResult[0] == topicWithKeyword2, "Topics are not ranked in the correct descending order of popularity")
            XCTAssert(searchResult[1] == topicWithKeyword, "Topics are not ranked in the correct descending order of popularity")
        }
    }
    
}

extension Topic {
    convenience init(_ id: String, _ name: String) {
        self.init(id, name, #imageLiteral(resourceName: "vegi-life"), " ", StringList(.User), StringList(.Post))
    }
    
    convenience init(_ id: String, _ name: String, _ posts: StringList) {
        self.init(id, name, #imageLiteral(resourceName: "vegi-life"), " ", StringList(.User), posts)
    }
}




