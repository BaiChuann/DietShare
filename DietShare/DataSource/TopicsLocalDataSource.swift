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
    private let imagePath = Expression<String>("imagePath")
    private let description = Expression<String>("description")
    private let popularity = Expression<Int>("popularity")
    private let posts = Expression<StringList>("posts")
    private let followers = Expression<StringList>("followers")
    
    // Initializer is private to prevent instantiation - Singleton Pattern
    private init(_ topics: [Topic], _ title: String) {
        print("TopicLocalDataSource initializer called")
//        removeDB()
        createDB(title)
        createTable()
        prepopulate(topics)
    }
    
    
    private convenience init() {
        self.init([Topic](), "topics")
        prepopulate()
    }
    
    
    
    // A shared instance to be used in a global scope
    static let shared = TopicsLocalDataSource()
    
    // Get instance for unit test
    static func getTestInstance(_ topics: [Topic]) -> TopicsLocalDataSource {
        return TopicsLocalDataSource(topics, "topicsTest")
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
        do {
            print("current topic id added: \(newTopic.getID())")
            try database.run(topicsTable.insert(id <- newTopic.getID(), name <- newTopic.getName(), description <- newTopic.getDescription(), imagePath <- newTopic.getImagePath(), popularity <- newTopic.getPopularity(), posts <- newTopic.getPostsID(), followers <- newTopic.getFollowersID()))
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
            self.addTopic(newTopic)
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
        if let fileUrl = documentDirectory?.appendingPathComponent("topics").appendingPathExtension("sqlite3") {
            try? FileManager.default.removeItem(at: fileUrl)
        }
    }
    
    // Only for testing
    private func prepopulate() {
        print("Prepopulated")
        let followers = ["1", "2", "3", "4", "5"]
        let followersSet = Set<String>(followers)
        let followerList = StringList(.User, followersSet)
        for i in 0..<50 {
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
    }
    
    private func prepopulate(_ topics: [Topic]) {
        if !topics.isEmpty {
            for topic in topics {
                if !containsTopic(topic.getID()) {
                    self.addTopic(topic)    
                }
            }
        }
    }
    
    
    func startQuery(_ query: Table) {
        
        print("entered query: \(query)")
        
        let start = CFAbsoluteTimeGetCurrent()
        do {
            
            let startTime = CFAbsoluteTimeGetCurrent()
            var initTime = CFAbsoluteTimeGetCurrent()
            
            for topic in try database.prepare(query) {
                
                print("Getting topic" + topic[id] + " iteration takes: \(CFAbsoluteTimeGetCurrent() - initTime)")
                initTime = CFAbsoluteTimeGetCurrent()
            }
            print("Time lapsed for getting topics: \(CFAbsoluteTimeGetCurrent() - startTime)")
        } catch let error {
            print("failed to get row: \(error)")
        }
        print("Total time taken: \(CFAbsoluteTimeGetCurrent() - start)")
    }
    
    
    func printQueries() {
        startQuery(topicsTable.select(id))
        startQuery(topicsTable.select(id, name))
        startQuery(topicsTable.select(id, name, description))
        startQuery(topicsTable.select(id, name, description, imagePath))
        startQuery(topicsTable.select(id, name, description, posts))
        startQuery(topicsTable)
    }
    
    
    // A C-API style function for testing
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
                
                let topicEntry = Topic(row[0] as! String, row[1] as! String,  row[3] as! String, row[2] as! String, StringList.fromDatatypeValue(row[5] as! Blob), StringList.fromDatatypeValue(row[6] as! Blob))
                topics.insert(topicEntry)
            }
        } else {
            print("SELECT statement could not be prepared")
        }
        sqlite3_finalize(queryStatement)
        print("query all takes time: \(CFAbsoluteTimeGetCurrent() - startTime)")
        return topics
    }
    
    func openDatabase() -> OpaquePointer? {
        var db: OpaquePointer? = nil
        let documentDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        if let fileUrl = documentDirectory?.appendingPathComponent("topics").appendingPathExtension("sqlite3") {
            if sqlite3_open(fileUrl.path, &db) == SQLITE_OK {
                print("Successfully opened connection to database at \(fileUrl)")
                return db
            }
        }
        return nil
    }
    
    
    // TODO - Check representation of the datasource
    private func checkRep() {
        
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
