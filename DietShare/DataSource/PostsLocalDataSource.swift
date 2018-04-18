//
//  PostsLocalDataSource.swift
//  DietShare
//
//  Created by baichuan on 17/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//  swiftlint:disable force_unwrapping

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
        let createTable = self.postsTable.create(ifNotExists: true) { table in
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
        
//        let dateFormatterGet = DateFormatter()
//        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
//
//        let newPost1 = Post(userId: "6", caption: "Today is a cheat-day. Had a lot of fat and protein.", time: dateFormatterGet.date(from: "2017-10-19 10:10:13")!, photo: UIImage(named: "topic1-1")!, restaurant: "12", topics: ["1"])
//        let newPost2 = Post(userId: "9", caption: "Yum yum. A big breakfast #healthy breakfast", time: dateFormatterGet.date(from: "2018-01-05 08:04:15")!, photo: UIImage(named: "topic1-2")!, restaurant: nil, topics: ["1"])
//        let newPost3 = Post(userId: "9", caption: "My 5-year-old daughter really love this dish", time: dateFormatterGet.date(from: "2016-11-30 09:39:27")!, photo: UIImage(named: "topic1-3")!, restaurant: "13", topics: ["1", "3"])
//        let newPost4 = Post(userId: "4", caption: "A really tasty salad made by myself.", time: dateFormatterGet.date(from: "2018-02-14 12:18:26")!, photo: UIImage(named: "topic1-4")!, restaurant: "13", topics: ["1", "7"])
//        let newPost5 = Post(userId: "3", caption: "This caesar salad is really food and balanced. Made my day!", time: dateFormatterGet.date(from: "2017-08-36 12:24:26")!, photo: UIImage(named: "topic1-5")!, restaurant: "19", topics: ["1"])
//        let newPost6 = Post(userId: "7", caption: "Day 36 in diet eating plan", time: dateFormatterGet.date(from: "2018-04-18 16:09:46")!, photo: UIImage(named: "topic1-6")!, restaurant: nil, topics: ["1"])
//        let newPost7 = Post(userId: "10", caption: "Try to have a vegetarian breakfast", time: dateFormatterGet.date(from: "2017-10-10 17:29:53")!, photo: UIImage(named: "topic1-7")!, restaurant: "5", topics: ["1", "9"])
//        let newPost8 = Post(userId: "9", caption: "Made a fish dish for my son. Omega 3 is good for his body", time: dateFormatterGet.date(from: "2018-01-01 07:35:37")!, photo: UIImage(named: "topic2-1")!, restaurant: nil, topics: ["2", "3"])
//        let newPost9 = Post(userId: "1", caption: "First time using collage feature of this App. Varieties of pictures suit my food", time: dateFormatterGet.date(from: "2016-02-29 12:24:26")!, photo: UIImage(named: "topic3-1")!, restaurant: "3", topics: ["3"])
//        let newPost11 = Post(userId: "4", caption: "OMG!!!! I will be 2kg heavier tmr!!! #1834CalPizza", time: dateFormatterGet.date(from: "2017-04-23 09:37:58")!, photo: UIImage(named: "topic3-2")!, restaurant: "1", topics: ["3"])
//        let newPost12 = Post(userId: "10", caption: "Where’s my yogurt? LOL", time: dateFormatterGet.date(from: "2016-11-06 13:45:39")!, photo: UIImage(named: "topic4-1")!, restaurant: nil, topics: ["4"])
//        let newPost13 = Post(userId: "3", caption: "I am growing fat! I saw myself when I saw this sticker.", time: dateFormatterGet.date(from: "2018-03-02 23:59:35")!, photo: UIImage(named: "topic4-2")!, restaurant: nil, topics: ["4"])
//        let newPost14 = Post(userId: "2", caption: "22g protein in 25g food. Btw, I am so surprised that this food can be recognized!", time: dateFormatterGet.date(from: "2018-03-29 12:15:18")!, photo: UIImage(named: "topic4-3")!, restaurant: "7", topics: ["4", "6"])
//        let newPost15 = Post(userId: "5", caption: "I DON’T LIKE SALAD. My wife forced me to eat it. #HealthyFoodSucks", time: dateFormatterGet.date(from: "2017-07-15 08:00:18")!, photo: UIImage(named: "topic5-1")!, restaurant: "25", topics: ["5"])
//        let newPost16 = Post(userId: "8", caption: "Tomatoes and olive oil. Should let my husband eat healthy food. He had high blood pressure, but he just like carrot cake.", time: dateFormatterGet.date(from: "2017-06-30 17:02:05")!, photo: UIImage(named: "topic5-2")!, restaurant: "1", topics: ["5"])
//        let newPost17 = Post(userId: "5", caption: "Meh. Maybe I just like unhealthy food. Much better than the salad my wife gave me. What’s the point having food tastes like nothing?", time: dateFormatterGet.date(from: "2017-04-30 14:23:27")!, photo: UIImage(named: "topic5-3")!, restaurant: "2", topics: ["5"])
//        let newPost18 = Post(userId: "6", caption: "Delicious and high in protein. My trainer’s recommendation. #GymDay", time: dateFormatterGet.date(from: "2017-05-01 20:34:28")!, photo: UIImage(named: "topic6-1")!, restaurant: "15", topics: ["19"])
//        let newPost19 = Post(userId: "4", caption: "Yangzhou Fried Rice! Looks as good as in the restaurant, right?", time: dateFormatterGet.date(from: "2017-07-21 22:21:34")!, photo: UIImage(named: "topic7-1")!, restaurant: nil, topics: ["7"])
//        let newPost20 = Post(userId: "4", caption: "Today is my father-in-law’s 60th birthday. Need to prove myself.", time: dateFormatterGet.date(from: "2016-04-15 19:03:47")!, photo: UIImage(named: "topic7-2")!, restaurant: nil, topics: ["7"])
//        let newPost21 = Post(userId: "2", caption: "Really easy to cook! Healthy and delicious!", time: dateFormatterGet.date(from: "2018-03-26 16:52:59")!, photo: UIImage(named: "topic7-3")!, restaurant: nil, topics: ["7"])
//        let newPost22 = Post(userId: "3", caption: "I will NEVER try this! My dad cooked a whole pot of paste!!! He REALLY need to learn how to cook. I think it tastes like chicken", time: dateFormatterGet.date(from: "2017-12-03 13:14:15")!, photo: UIImage(named: "topic7-4")!, restaurant: nil, topics: ["3", "6", "7"])
//        let newPost23 = Post(userId: "1", caption: "Unsaturated fat can protect your vessel and heart. I just can resist things with avocado #AvocadeAddict", time: dateFormatterGet.date(from: "2017-12-20 08:09:10")!, photo: UIImage(named: "topic8-1")!, restaurant: "1", topics: ["8"])
//        let newPost24 = Post(userId: "9", caption: "Don’t be beguiled by its appearance. It tastes really goooood!!", time: dateFormatterGet.date(from: "2017-11-20 09:35:13")!, photo: UIImage(named: "topic8-2")!, restaurant: nil, topics: ["8"])
//        let newPost25 = Post(userId: "7", caption: "Looks like leaves. Tastes like leaves. After eating a whole bowl of this, I feel I am a vegetable walking. Meh.", time: dateFormatterGet.date(from: "2018-01-19 18:34:10")!, photo: UIImage(named: "topic9-1")!, restaurant: "15", topics: ["5", "9"])
//        let newPost26 = Post(userId: "10", caption: "Vegan food can be really palatable! Should let my family have vegan food once a week!", time: dateFormatterGet.date(from: "2017-0-11 20:54:00")!, photo: UIImage(named: "topic9-2")!, restaurant: "16", topics: ["9"])
//        let newPost27 = Post(userId: "1", caption: "My grandma cooked my favorite biryani for me. I really missed this taste in the last exchange year in States! Americans should at least learn how to cook edible Asian food for Asians.", time: dateFormatterGet.date(from: "2018-02-14 11:57:04")!, photo: UIImage(named: "topic9-3")!, restaurant: nil, topics: ["7", "9"])
//        addPost(newPost1)
//        addPost(newPost2)
//        addPost(newPost3)
//        addPost(newPost4)
//        addPost(newPost5)
//        addPost(newPost6)
//        addPost(newPost7)
//        addPost(newPost8)
//        addPost(newPost9)
//        //addPost(newPost10)
//        addPost(newPost11)
//        addPost(newPost12)
//        addPost(newPost13)
//        addPost(newPost14)
//        addPost(newPost15)
//        addPost(newPost16)
//        addPost(newPost17)
//        addPost(newPost18)
//        addPost(newPost19)
//        addPost(newPost20)
//        addPost(newPost21)
//        addPost(newPost22)
//        addPost(newPost23)
//        addPost(newPost24)
//        addPost(newPost25)
//        addPost(newPost26)
//        addPost(newPost27)
    }
}
