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
    private var topicsTable = Table("topics")
    private var IDList = [String]()
    
    // Columns of the topics table
    private let id = Expression<String>("id")
    private let name = Expression<String>("name")
    private let image = Expression<UIImage>("image")
    private let description = Expression<String>("description")
    private let popularity = Expression<Int>("popularity")
    private let posts = Expression<StringList>("posts")
    private let followers = Expression<StringList>("followers")
    
    // Initializer is private to prevent instantiation - Singleton Pattern
    private init(_ topics: [Topic]) {
        print("TopicLocalDataSource initializer called")
//        removeDB()
        createDB()
        createTable()
        do {
            try self.database.execute("PRAGMA locking_mode = EXCLUSIVE")
            try self.database.execute("PRAGMA journal_mode = WAL")
            print("topics: data base mode set")
        } catch let error {
            print("topics: fail to set locking mode: \(error)")
        }
        
        prepopulate(topics)
    }
    
    
    private convenience init() {
        self.init([Topic]())
        prepopulate()
    }
    
    
    // A shared instance to be used in a global scope
    static let shared = TopicsLocalDataSource()
    
    // Get instance for unit test
    static func getTestInstance(_ topics: [Topic]) -> TopicsLocalDataSource {
        return TopicsLocalDataSource(topics)
    }
    
    private func createDB() {
        
        let documentDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        if let fileUrl = documentDirectory?.appendingPathComponent("topics").appendingPathExtension("sqlite3") {
            self.database = try? Connection(fileUrl.path)
        }
    }
    
    // Creates topic table if it is not already existing
    private func createTable() {
        let createTable = self.topicsTable.create(ifNotExists: true) { (table) in
            table.column(self.id, primaryKey: true)
            table.column(self.name)
            table.column(self.description)
            table.column(self.image)
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
    
    // Get a specified number of topics starting at the provided index
    func getTopics(_ index: Int, _ number: Int) -> [Topic] {
        
        var topics = [Topic]()
        
        // if provided index exceeds the number of topics in the table, return an empty result
        if index > self.getNumOfTopics() {
            return topics
        }
        
        let start = CFAbsoluteTimeGetCurrent()
        var idx = index
        while idx < self.getNumOfTopics() && idx < index + number {
            DispatchQueue.global(qos: .default).sync { () -> Void in
                let row = topicsTable.limit(1, offset: idx)
                do {
                    var initTime = CFAbsoluteTimeGetCurrent()
                    for topic in try self.database.prepare(row) {
                        let topicEntry = Topic(topic[self.id], topic[self.name], topic[self.image], topic[self.description], topic[self.followers], topic[self.posts])
                        topics.append(topicEntry)
//                        print("Topic inserted: \(topic[self.id]) takes time: \(CFAbsoluteTimeGetCurrent() - initTime)")
                        initTime = CFAbsoluteTimeGetCurrent()
                    }
                } catch {
                    print("get topic failed: \(error)")
                }
            }
            idx += 1
        }
        print("Get \(number) topics cost: \(CFAbsoluteTimeGetCurrent() - start)")
        return topics
    }
    
    func getTopics() -> SortedSet<Topic> {
        var topics = SortedSet<Topic>()
        let startTime = CFAbsoluteTimeGetCurrent()
        let queue = DispatchQueue(label: "topicDbQueue", attributes: .concurrent)
        let group = DispatchGroup()
        IDList = getAllIDs()
        print("time used to get IDs: \(CFAbsoluteTimeGetCurrent() - startTime)")
        let midTime = CFAbsoluteTimeGetCurrent()
        for ID in IDList {
            group.enter()
            queue.sync { () -> Void in
                let row = self.topicsTable.select(*).filter(self.id == ID)
                do {
                    var initTime = CFAbsoluteTimeGetCurrent()
                    for topic in try self.database.prepare(row) {
                        let topicEntry = Topic(topic[self.id], topic[self.name], topic[self.image], topic[self.description], topic[self.followers], topic[self.posts])
                        topics.insert(topicEntry)
                        print("Topic inserted: \(ID) takes time: \(CFAbsoluteTimeGetCurrent() - initTime)")
                        initTime = CFAbsoluteTimeGetCurrent()
                    }
                } catch {
                    print("get topic failed: \(error)")
                }
                group.leave()
            }
        }
        group.wait()
        print("time used to get topics: \(CFAbsoluteTimeGetCurrent() - midTime)")
       
//        do {
//
//            let startTime = CFAbsoluteTimeGetCurrent()
//            for topic in try database.prepare(topicsTable) {
//                let topicEntry = Topic(topic[id], topic[name], topic[image], topic[description], topic[followers], topic[posts])
//                topics.insert(topicEntry)
//            }
//            print("Time lapsed for getting topics: \(CFAbsoluteTimeGetCurrent() - startTime)")
//        } catch let error {
//            print("failed to get row: \(error)")
//        }
        return topics
    }
    
    private func getAllIDs() -> [String] {
        let IDcolumn = topicsTable.select(id)
        var IDs = [String]()
        do {
            for ID in try database.prepare(IDcolumn) {
                IDs.append(ID[id])
            }
        } catch let error {
            print("delete failed: \(error)")
        }
        
        return IDs
    }
    
    private var db: OpaquePointer?
    
    func queryAllTopics() -> SortedSet<Topic> {
        
        let startTime = CFAbsoluteTimeGetCurrent()
        
        var topics = SortedSet<Topic>()
        let queryStatementString = "SELECT * FROM topics;"
        var queryStatement: OpaquePointer? = nil
        db = self.database.handle
        if sqlite3_prepare_v2(db, queryStatementString, -1, &queryStatement, nil) == SQLITE_OK {
            
            let columnCount = sqlite3_column_count(queryStatement)
            while (sqlite3_step(queryStatement) == SQLITE_ROW) {
                var row = [Any?]()
                for idx in 0..<columnCount {
                    switch sqlite3_column_type(queryStatement, Int32(idx)) {
                    case SQLITE_BLOB:
                        let bytes = sqlite3_column_blob(queryStatement, Int32(idx))
                        let length = sqlite3_column_bytes(queryStatement, Int32(idx))
                        row.append(Blob(bytes: bytes!, length: Int(length)))
                    case SQLITE_FLOAT:
                        row.append(Double(sqlite3_column_double(queryStatement, Int32(idx))))
                    case SQLITE_INTEGER:
                        let int = Int(sqlite3_column_int64(queryStatement, Int32(idx)))
                        var bool = false
                        let type = String(cString: sqlite3_column_decltype(queryStatement, Int32(idx)))
                        bool = type.hasPrefix("BOOL")
                        row.append(bool ? int != 0 : int)
                    case SQLITE_NULL:
                        row.append(nil)
                    case SQLITE_TEXT:
                        row.append(String(cString: sqlite3_column_text(queryStatement, Int32(idx))))
                    case let type:
                        assertionFailure("unsupported column type: \(type)")
                    }
                }
                
                let topicEntry = Topic(row[0] as! String, row[1] as! String,  UIImage.fromDatatypeValue(row[3] as! Blob), row[2] as! String, StringList.fromDatatypeValue(row[5] as! Blob), StringList.fromDatatypeValue(row[6] as! Blob))
                topics.insert(topicEntry)
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        print("query all takes time: \(CFAbsoluteTimeGetCurrent() - startTime)")
        return topics
    }
    
    
    func addTopic(_ newTopic: Topic) {
        do {
            print("current topic id is: \(newTopic.getID())")
            try database.run(topicsTable.insert(id <- newTopic.getID(), name <- newTopic.getName(), description <- newTopic.getDescription(), image <- newTopic.getImage(), popularity <- newTopic.getPopularity(), posts <- newTopic.getPostsID(), followers <- newTopic.getFollowersID()))
            topicsTable = topicsTable.order(popularity.desc)
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("insert constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            print("insertion failed: \(error)")
        }
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
        for newTopic in newTopics {
            addTopic(newTopic)
        }
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
    }
    
    func updateTopic(_ oldTopicID: String, _ newTopic: Topic) {
        let row = topicsTable.filter(id == oldTopicID)
        do {
            if try database.run(row.update(name <- newTopic.getName(), description <- newTopic.getDescription(), image <- newTopic.getImage(), popularity <- newTopic.getPopularity(), posts <- newTopic.getPostsID(), followers <- newTopic.getFollowersID())) > 0 {
                print("Old topic is updated")
                topicsTable = topicsTable.order(popularity.desc)
            } else {
                print("Old topic not found")
            }
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("update constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            print("update failed: \(error)")
        }
    }
    
    
    /**
     * For post publish component
     */
    func searchWithKeyword(_ keyword: String) -> [Topic] {
        var topics = [Topic]()
        let query = topicsTable.filter(name.match(keyword + "*")).order(popularity.desc)
        do {
            for topic in try database.prepare(query) {
                let topicEntry = Topic(topic[id], topic[name], topic[image], topic[description], topic[followers], topic[posts])
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
        if let fileUrl = documentDirectory?.appendingPathComponent("topics").appendingPathExtension("sqlite3") {
            try? FileManager.default.removeItem(at: fileUrl)
        }
    }
    
    // Only for testing
    private func prepopulate() {
        print("Prepopulated")
        if !containsTopic("1") {
            let followers = ["1", "2", "3", "4", "5"]
            let followersSet = Set<String>(followers)
            let followerList = StringList(.User, followersSet)
            for i in 0..<30 {
                let topic = Topic(String(i), "VegiLife", #imageLiteral(resourceName: "vegi-life"), "A little bit of Vegi goes a long way", followerList, StringList(.Post))
                self.addTopic(topic)
            }
        }
    }
    
    private func prepopulate(_ topics: [Topic]) {
        if !topics.isEmpty && !containsTopic(topics[0].getID()) {
            for topic in topics {
                self.addTopic(topic)
            }
        }
    }
    
    
    // TODO - Check representation of the datasource
    private func checkRep() {
        
    }
    
}

extension UIImage: Value {
    public class var declaredDatatype: String {
        return Blob.declaredDatatype
    }
    public class func fromDatatypeValue(_ blobValue: Blob) -> UIImage {
        return UIImage(data: Data.fromDatatypeValue(blobValue))!
    }
    public var datatypeValue: Blob {
        return UIImagePNGRepresentation(self)!.datatypeValue
    }
    
}
