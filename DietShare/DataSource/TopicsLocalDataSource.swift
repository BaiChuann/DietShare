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
    private let activeUsers = Expression<IDList>("activeUsers")
    
    // Initializer is private to prevent instantiation - Singleton Pattern
    private init() {
        createDB()
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
        let createTable = self.topicsTable.create(block: { (table) in
            table.column(self.id, primaryKey: true)
            table.column(self.name, unique: true)
            table.column(self.description)
            table.column(self.image)
            table.column(self.popularity)
            table.column(self.posts)
            table.column(self.activeUsers)
        })
        do {
            try self.database.run(createTable)
        } catch {
            fatalError("Database not created")
        }
    }
    
    func getTopics() -> SortedSet<Topic> {
        var topics = SortedSet<Topic>()
        do {
            for topic in try database.prepare(topicsTable) {
                let topicEntry = Topic(topic[id], topic[name], topic[image], topic[description], topic[activeUsers], topic[posts])
                topics.insert(topicEntry)
            }
        } catch let error {
            print("failed to get row: \(error)")
        }
        return topics
    }
    
    func addTopic(_ newTopic: Topic) {
        do {
            try database.run(topicsTable.insert(id <- newTopic.getID(), name <- newTopic.getName(), description <- newTopic.getDescription(), image <- newTopic.getImage(), popularity <- newTopic.getPopularity(), posts <- newTopic.getPostsID(), activeUsers <- newTopic.getActiveUsersID()))
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            print("insertion failed: \(error)")
        }
    }
    
    
    func addTopics(_ newTopics: SortedSet<Topic>) {
        for newTopic in newTopics {
            addTopic(newTopic)
        }
    }
    
    func deleteTopic(_ topic: Topic) {
        let row = topicsTable.filter(id == topic.getID())
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
    
    func updateTopic(_ oldTopic: Topic, _ newTopic: Topic) {
        let row = topicsTable.filter(id == oldTopic.getID())
        do {
            if try database.run(row.update(id <- newTopic.getID(), name <- newTopic.getName(), description <- newTopic.getDescription(), image <- newTopic.getImage(), popularity <- newTopic.getPopularity(), posts <- newTopic.getPostsID(), activeUsers <- newTopic.getActiveUsersID())) > 0 {
                print("Old topic is updated")
            } else {
                print("Old topic not found")
            }
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            print("update failed: \(error)")
        }
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
