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
    private let topicsTable = Table("topics")
    
    // Columns of the topics table
    private let id = Expression<String>("id")
    private let name = Expression<String>("name")
    private let image = Expression<UIImage>("image")
    private let description = Expression<String>("description")
    private let popularity = Expression<Int>("popularity")
    private let posts = Expression<IDList>("posts")
    private let followers = Expression<IDList>("followers")
    
    // Initializer is private to prevent instantiation - Singleton Pattern
    private init() {
        print("initializer called")
        
//        removeDB()
        createDB()
        createTable()
//        prepopulate()
    }
    
    
    
    // A shared instance to be used in a global scope
    static let shared = TopicsLocalDataSource()
    
    private func createDB() {
        
        let documentDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        if let fileUrl = documentDirectory?.appendingPathComponent("topics").appendingPathExtension("sqlite3") {
            self.database = try? Connection(fileUrl.path)
        }
    }
    
    
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
    
    func getTopics() -> SortedSet<Topic> {
        var topics = SortedSet<Topic>()
        do {
            for topic in try database.prepare(topicsTable) {
//                let start = CFAbsoluteTimeGetCurrent()
                let topicEntry = Topic(topic[id], topic[name], topic[image], topic[description], topic[followers], topic[posts])
//                let intm = CFAbsoluteTimeGetCurrent()
//                print("Getting entry \(topic[id]) takes time: \(intm - start)")
                topics.insert(topicEntry)
                let end = CFAbsoluteTimeGetCurrent()
                print("End time for \(topic[id]): \(end)")
            }
        } catch let error {
            print("failed to get row: \(error)")
        }
        
        return topics
    }
    
    func addTopic(_ newTopic: Topic) {
        do {
            print("current id is: \(newTopic.getID())")
            try database.run(topicsTable.insert(id <- newTopic.getID(), name <- newTopic.getName(), description <- newTopic.getDescription(), image <- newTopic.getImage(), popularity <- newTopic.getPopularity(), posts <- newTopic.getPostsID(), followers <- newTopic.getFollowersID()))
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("insert constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            print("insertion failed: \(error)")
        }
    }
    
    
    func addTopics(_ newTopics: SortedSet<Topic>) {
        for newTopic in newTopics {
            addTopic(newTopic)
        }
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
            if try database.run(row.update(id <- newTopic.getID(), name <- newTopic.getName(), description <- newTopic.getDescription(), image <- newTopic.getImage(), popularity <- newTopic.getPopularity(), posts <- newTopic.getPostsID(), followers <- newTopic.getFollowersID())) > 0 {
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
        for i in 0..<20 {
            let topic = Topic(String(i), "VegiLife", #imageLiteral(resourceName: "vegi-life"), "A little bit of Vegi goes a long way", IDList(.User), IDList(.Post))
            self.addTopic(topic)
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
