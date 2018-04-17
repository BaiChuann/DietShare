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

/**
 * A local data source for topics, implemented with SQLite.
 */
class TopicsLocalDataSource: TopicsDataSource {
    
    private var database: Connection!
    private var topicsTable = Table(Constants.Tables.topics)
    private var IDList = [String]()
    
    // Columns of the topics table
    private let id = Expression<String>("id")
    private let name = Expression<String>("name")
    private let imagePath = Expression<String>("imagePath")
    private let description = Expression<String>("description")
    private let popularity = Expression<Int>("popularity")
    private let posts = Expression<StringList>("posts")
    private let followers = Expression<StringList>("followers")
    
    // Initializer is private to prevent instantiation - Singleton Pattern
    private init(_ topics: [Topic], _ title: String) {
//        print("TopicLocalDataSource initializer called")
        removeDB()
        createDB(title)
        createTable()
        prepopulate(topics)
    }
    
    
    private convenience init() {
        self.init([Topic](), Constants.Tables.topics)
        prepopulate()
    }
    
    
    
    // A shared instance to be used in a global scope
    static let shared = TopicsLocalDataSource()
    
    // Get instance for unit test
    static func getTestInstance(_ topics: [Topic]) -> TopicsLocalDataSource {
        return TopicsLocalDataSource(topics, Constants.Tables.topics + "Test")
    }
    
    private func createDB(_ title: String) {
        
        let documentDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        if let fileUrl = documentDirectory?.appendingPathComponent(title).appendingPathExtension("sqlite3") {
            self.database = try? Connection(fileUrl.path)
        }
    }
    
    // Creates topic table if it is not already existing
    private func createTable() {
        let createTable = self.topicsTable.create(ifNotExists: true) { (table) in
            table.column(self.id, primaryKey: true)
            table.column(self.name)
            table.column(self.description)
            table.column(self.imagePath)
            table.column(self.popularity)
            table.column(self.posts)
            table.column(self.followers)
        }
        do {
            try self.database.run(createTable)
        } catch {
            fatalError("Table not created")
        }
    }
    
    
    func getAllTopics() -> SortedSet<Topic> {
        var topics = SortedSet<Topic>()
        do {
            for topic in try database.prepare(topicsTable) {
                let topicEntry = Topic(topic[id], topic[name], topic[imagePath], topic[description], topic[followers], topic[posts])
                topics.insert(topicEntry)
            }
        } catch let error {
            print("failed to get row: \(error)")
        }
        return topics
    }
    
    
    func addTopic(_ newTopic: Topic) {
        _checkRep()
        do {
//            print("current topic id added: \(newTopic.getID())")
            try database.run(topicsTable.insert(id <- newTopic.getID(), name <- newTopic.getName(), description <- newTopic.getDescription(), imagePath <- newTopic.getImagePath(), popularity <- newTopic.getPopularity(), posts <- newTopic.getPostsID(), followers <- newTopic.getFollowersID()))
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("insert constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            print("insertion failed: \(error)")
        }
        _checkRep()
    }
    
    func getNumOfTopics() -> Int {
        var count = 0
        do {
            count = try database.scalar(topicsTable.count)
        } catch let error {
            print("failed to count number of rows: \(error)")
        }
        return count
    }
    
    func addTopics(_ newTopics: SortedSet<Topic>) {
        _checkRep()
        for newTopic in newTopics {
            self.addTopic(newTopic)
        }
        _checkRep()
    }
    
    func containsTopic(_ topicID: String) -> Bool {
        let row = topicsTable.filter(id == topicID)
        do {
            if try database.run(row.update(id <- topicID)) > 0 {
                return true
            }
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("update constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            print("update failed: \(error)")
        }
        return false
    }
    
    func deleteTopic(_ topicID: String) {
        _checkRep()
        let row = topicsTable.filter(id == topicID)
        do {
            if try database.run(row.delete()) > 0 {
                print("deleted the topic")
            } else {
                print("topic not found")
            }
        } catch {
            print("delete failed: \(error)")
        }
        _checkRep()
    }
    
    func updateTopic(_ oldTopicID: String, _ newTopic: Topic) {
        _checkRep()
        let row = topicsTable.filter(id == oldTopicID)
        do {
            if try database.run(row.update(name <- newTopic.getName(), description <- newTopic.getDescription(), imagePath <- newTopic.getImagePath(), popularity <- newTopic.getPopularity(), posts <- newTopic.getPostsID(), followers <- newTopic.getFollowersID())) > 0 {
                print("Old topic is updated")
            } else {
                print("Old topic not found")
            }
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("update constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            print("update failed: \(error)")
        }
        _checkRep()
    }
    
    
    /**
     * For post publish component
     */
    func searchWithKeyword(_ keyword: String) -> [Topic] {
        var topics = [Topic]()
        let query = topicsTable.filter(name.like("%\(keyword)%")).order(popularity.desc)
        do {
            for topic in try database.prepare(query) {
                let topicEntry = Topic(topic[id], topic[name], topic[imagePath] , topic[description], topic[followers], topic[posts])
                topics.append(topicEntry)
            }
        } catch let error {
            print("failed to get row: \(error)")
        }
        
        return topics
    }
    
    
    /**
     * Test functions - to be removed
     */
    
    // MARK: Only for test purpose
    private func removeDB() {
        print("Remove DB called")
        let documentDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        if let fileUrl = documentDirectory?.appendingPathComponent(Constants.Tables.topics).appendingPathExtension("sqlite3") {
            try? FileManager.default.removeItem(at: fileUrl)
        }
    }
    
    // Only for testing
    private func prepopulate() {
        _checkRep()
        let followers = ["1", "2", "3", "4", "5"]
        let followersSet = Set<String>(followers)
        let followerList = StringList(.User, followersSet)
        for i in 0..<20 {
            if !containsTopic("i") {
                let topic = Topic(String(i), "VegiLife", "vegi-life.png", "A little bit of Vegi goes a long way", followerList, StringList(.Post))
                self.addTopic(topic)
            }
        }
        if !containsTopic("100000") {
            let posts = ["1", "2", "3", "4", "5", "6"]
            let postsSet = Set<String>(posts)
            let postsList = StringList(.Post, postsSet)
            let topic = Topic("100000", "High_Popularity2", "vegi-life.png", "Slightly lower popularity", StringList(.User), postsList)
            self.addTopic(topic)
        }
        _checkRep()
    }
    
    private func prepopulate(_ topics: [Topic]) {
        _checkRep()
        if !topics.isEmpty {
            for topic in topics {
                if !containsTopic(topic.getID()) {
                    self.addTopic(topic)    
                }
            }
        }
        _checkRep()
    }
    
    
    // Check representation of the datasource
    private func _checkRep() {
        assert(checkIDUniqueness(), "IDs should be unique")
        assert(checkColumnUniqueness(), "Column titles should be unique")
    }
    
    private func checkIDUniqueness() -> Bool {
        var IdSet = Set<String>()
        var IdArray = [String]()
        do {
            for Id in try database.prepare(topicsTable.select(id)) {
                IdArray.append(Id[id])
                IdSet.insert(Id[id])
                if IdSet.count != IdSet.count {
                    return false
                }
            }
        } catch let error {
            print("failed to get row: \(error)")
        }
        
        return true
    }
    
    private func checkColumnUniqueness() -> Bool {
        var columnNameSet = Set<String>()
        var columnNameArray = [String]()
        do {
            let tableInfo = try database.prepare("PRAGMA table_info(table_name)")
            for line in tableInfo {
                columnNameSet.insert(line[1] as! String)
                columnNameArray.append(line[1] as! String)
                if columnNameArray.count != columnNameSet.count {
                    return false
                }
            }
        } catch let error {
            print("failed to get row: \(error)")
        }
        
        return true
    }
}


extension UIImage: Value {
    public class var declaredDatatype: String {
        return String.declaredDatatype
    }
    public class func fromDatatypeValue(_ stringValue: String) -> UIImage {
        let dataDecoded: Data = Data(base64Encoded: stringValue, options: .ignoreUnknownCharacters)!
        let image = UIImage(data: dataDecoded)!
        return image
    }
    public var datatypeValue: String {
        let imageData: Data = UIImagePNGRepresentation(self)!
        let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
        return strBase64
    }
}



