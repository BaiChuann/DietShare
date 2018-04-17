//
//  PostsLocalDataSource.swift
//  DietShare
//
//  Created by baichuan on 17/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit
import SQLite

/**
 * A local data source for Users, implemented with SQLite.
 */
class PostsLocalDataSource {
    private var database: Connection!
    private let postsTable = Table(Constants.Tables.posts)
    
    // Columns of the Users table
    private let postId = Expression<String>("postId")
    private let userId = Expression<String>("userId")
    private let caption = Expression<String>("caption")
    private let time = Expression<Date>("time")
    private let photo = Expression<String>("photo")
    private let restaurant = Expression<String>("restaurant")
    private let topics = Expression<StringList>("topics")
    private let commentsCount = Expression<Int>("commentsCount")
    private let likesCount = Expression<Int>("likesCount")
    
    // Initializer is private to prevent instantiation - Singleton Pattern
    private init(_ posts: [Post], _ title: String) {
        //        print("UserLocalDataSource initializer called")
        removeDB()
        createDB(title)
        createTable()
    }
    
    private convenience init() {
        self.init([Post](), Constants.Tables.posts)
        prepopulate()
    }
    
    // A shared instance to be used in a global scope
    static let shared = PostsLocalDataSource()
    
    // Get instance for unit test
    static func getTestInstance(_ posts: [Post]) -> PostsLocalDataSource {
        return PostsLocalDataSource(posts, Constants.Tables.posts + "Test")
    }
    
    // Create a database connection with given title, if such database does not already exist
    private func createDB(_ title: String) {
        let documentDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        if let fileUrl = documentDirectory?.appendingPathComponent(title).appendingPathExtension("sqlite3") {
            
            self.database = try? Connection(fileUrl.path)
        }
    }
    
    // Creates user table if it is not already existing
    private func createTable() {
        let createTable = self.postsTable.create(ifNotExists: true) { (table) in
            table.column(self.postId, primaryKey: true)
            table.column(self.userId)
            table.column(self.caption)
            table.column(self.time)
            table.column(self.photo)
            table.column(self.restaurant)
            table.column(self.topics)
            table.column(self.commentsCount)
            table.column(self.likesCount)
        }
        do {
            try self.database.run(createTable)
        } catch {
            fatalError("Database not created")
        }
    }
    
    func getAllPosts() -> [Post] {
        var posts = [Post]()
        do {
            let startTime = CFAbsoluteTimeGetCurrent()
            for post in try database.prepare(postsTable) {
                
                let postEntry = Post(userId: post[userId], caption: post[caption], time: post[time], photo: UIImage(data:Data(base64Encoded: post[photo], options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!)!, restaurant: post[restaurant], topics: post[topics].getListAsArray())
                posts.append(postEntry)
            }
            
            print("Time lapsed for getting users: \(CFAbsoluteTimeGetCurrent() - startTime)")
        } catch let error {
            print("failed to get row: \(error)")
        }
        return posts
    }
    
    
    func addPost(_ newPost: Post) {
        do {
            //            print("current user id is: \(newUser.getUserId())")
            let imageData = UIImagePNGRepresentation(newPost.getPhoto())!
            let newPhoto = imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
            let newTopics = StringList(.Post)
            newTopics.addEntries(newPost.getTopics()!)
            try database.run(postsTable.insert(postId <- newPost.getPostId(), userId <- newPost.getUserId(), caption <- newPost.getCaption(), time <- newPost.getTime(), photo <- newPhoto, restaurant <- newPost.getRestaurant()!, topics <- newTopics, commentsCount <- newPost.getCommentsCount(), likesCount <- newPost.getLikesCount()))
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("insert constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            print("insertion failed: \(error)")
        }
    }
    
    /**
     * Test functions - to be removed
     */
    
    // MARK: Only for test purpose
    private func removeDB() {
        print("Remove DB called")
        let documentDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        if let fileUrl = documentDirectory?.appendingPathComponent(Constants.Tables.posts).appendingPathExtension("sqlite3") {
            try? FileManager.default.removeItem(at: fileUrl)
        }
    }
    
    // Only for testing
    
    private func prepopulate() {
        
        for i in 1...20 {
            let newPost = Post(userId: String(i), caption: "today I ate this thing it was super niceeeeee", time: Date(), photo: UIImage(named: "post-example")!, restaurant: "koufu", topics: ["1", "2", "3", "4", "5"])
            addPost(newPost)
        }
        let newPost1 = Post(userId: "1", caption: "Today is a cheat-day. Had a lot of fat and protein.", time: Date(), photo: UIImage(named: "topic1-1")!, restaurant: nil, topics: ["1"])
        let newPost2 = Post(userId: "1", caption: "Today is a cheat-day. Had a lot of fat and protein.", time: Date(), photo: UIImage(named: "topic1-1")!, restaurant: nil, topics: ["1"])
        let newPost3 = Post(userId: "1", caption: "Today is a cheat-day. Had a lot of fat and protein.", time: Date(), photo: UIImage(named: "topic1-1")!, restaurant: nil, topics: ["1"])
        let newPost4 = Post(userId: "1", caption: "Today is a cheat-day. Had a lot of fat and protein.", time: Date(), photo: UIImage(named: "topic1-1")!, restaurant: nil, topics: ["1"])
        let newPost5 = Post(userId: "1", caption: "Today is a cheat-day. Had a lot of fat and protein.", time: Date(), photo: UIImage(named: "topic1-1")!, restaurant: nil, topics: ["1"])
        let newPost6 = Post(userId: "1", caption: "Today is a cheat-day. Had a lot of fat and protein.", time: Date(), photo: UIImage(named: "topic1-1")!, restaurant: nil, topics: ["1"])
        let newPost7 = Post(userId: "1", caption: "Today is a cheat-day. Had a lot of fat and protein.", time: Date(), photo: UIImage(named: "topic1-1")!, restaurant: nil, topics: ["1"])
        let newPost8 = Post(userId: "1", caption: "Today is a cheat-day. Had a lot of fat and protein.", time: Date(), photo: UIImage(named: "topic1-1")!, restaurant: nil, topics: ["1"])
        let newPost9 = Post(userId: "1", caption: "Today is a cheat-day. Had a lot of fat and protein.", time: Date(), photo: UIImage(named: "topic1-1")!, restaurant: nil, topics: ["1"])
        let newPost10 = Post(userId: "1", caption: "Today is a cheat-day. Had a lot of fat and protein.", time: Date(), photo: UIImage(named: "topic1-1")!, restaurant: nil, topics: ["1"])
        let newPost11 = Post(userId: "1", caption: "Today is a cheat-day. Had a lot of fat and protein.", time: Date(), photo: UIImage(named: "topic1-1")!, restaurant: nil, topics: ["1"])
        let newPost12 = Post(userId: "1", caption: "Today is a cheat-day. Had a lot of fat and protein.", time: Date(), photo: UIImage(named: "topic1-1")!, restaurant: nil, topics: ["1"])
        let newPost13 = Post(userId: "1", caption: "Today is a cheat-day. Had a lot of fat and protein.", time: Date(), photo: UIImage(named: "topic1-1")!, restaurant: nil, topics: ["1"])
        let newPost14 = Post(userId: "1", caption: "Today is a cheat-day. Had a lot of fat and protein.", time: Date(), photo: UIImage(named: "topic1-1")!, restaurant: nil, topics: ["1"])
        let newPost15 = Post(userId: "1", caption: "Today is a cheat-day. Had a lot of fat and protein.", time: Date(), photo: UIImage(named: "topic1-1")!, restaurant: nil, topics: ["1"])
        let newPost16 = Post(userId: "1", caption: "Today is a cheat-day. Had a lot of fat and protein.", time: Date(), photo: UIImage(named: "topic1-1")!, restaurant: nil, topics: ["1"])
        let newPost17 = Post(userId: "1", caption: "Today is a cheat-day. Had a lot of fat and protein.", time: Date(), photo: UIImage(named: "topic1-1")!, restaurant: nil, topics: ["1"])
        let newPost18 = Post(userId: "1", caption: "Today is a cheat-day. Had a lot of fat and protein.", time: Date(), photo: UIImage(named: "topic1-1")!, restaurant: nil, topics: ["1"])
        
    }
    
}




