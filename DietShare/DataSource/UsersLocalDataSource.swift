//
//  UsersLocalDataSource.swift
//  DietShare
//
//  Created by Shuang Yang on 11/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit
import SQLite

/**
 * A local data source for Users, implemented with SQLite.
 */
class UsersLocalDataSource: UsersDataSource {
    
    private var database: Connection!
    private let usersTable = Table(Constants.Tables.users)
    
    // Columns of the Users table
    private let id = Expression<String>("id")
    private let name = Expression<String>("name")
    private let password = Expression<String>("password")
    private let image = Expression<String>("image")
    
    // Initializer is private to prevent instantiation - Singleton Pattern
    private init(_ users: [User], _ title: String) {
//        print("UserLocalDataSource initializer called")
        removeDB()
        createDB(title)
        createTable()
        prepopulate(users)
    }
    
    private convenience init() {
        self.init([User](), Constants.Tables.users)
        prepopulate()
    }
    
    // A shared instance to be used in a global scope
    static let shared = UsersLocalDataSource()
    
    // Get instance for unit test
    static func getTestInstance(_ users: [User]) -> UsersLocalDataSource {
        return UsersLocalDataSource(users, Constants.Tables.users + "Test")
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
        let createTable = self.usersTable.create(ifNotExists: true) { (table) in
            table.column(self.id, primaryKey: true)
            table.column(self.name)
            table.column(self.password)
            table.column(self.image)
        }
        do {
            try self.database.run(createTable)
        } catch {
            fatalError("Database not created")
        }
    }
    
    func getAllUsers() -> [User] {
        var users = [User]()
        do {
            
            let startTime = CFAbsoluteTimeGetCurrent()
            for user in try database.prepare(usersTable) {
                
                let userEntry = User(userId: user[id], name: user[name], password: user[password], photo: user[image])
                users.append(userEntry)
            }
            
            print("Time lapsed for getting users: \(CFAbsoluteTimeGetCurrent() - startTime)")
        } catch let error {
            print("failed to get row: \(error)")
        }
        return users
    }
    
    func getUserFromID(_ userID: String) -> User? {
        _checkRep()
        do {
            let row = usersTable.filter(id == userID)
            for user in try database.prepare(row) {
                let userEntry = User(userId: user[id], name: user[name], password: user[password], photo: user[image])
                return userEntry
            }
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("query constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            print("query failed: \(error)")
        }
        _checkRep()
        return nil
    }
    
    func getNumOfUsers() -> Int {
        var count = 0
        do {
            count = try database.scalar(usersTable.count)
        } catch let error {
            print("failed to count number of rows: \(error)")
        }
        return count
    }
    
    func addUser(_ newUser: User) {
        _checkRep()
        do {
//            print("current user id is: \(newUser.getUserId())")
            try database.run(usersTable.insert(id <- newUser.getUserId(), name <- newUser.getName(), password <- newUser.getPassword(), image <- newUser.getPhotoAsPath()))
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("insert constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            print("insertion failed: \(error)")
        }
        _checkRep()
    }
    
    
    func addUsers(_ newUsers: [User]) {
        _checkRep()
        for newUser in newUsers {
            addUser(newUser)
        }
        _checkRep()
    }
    
    func containsUser(_ userID: String) -> Bool {
        let row = usersTable.filter(id == userID)
        do {
            if try database.run(row.update(id <- userID)) > 0 {
                return true
            }
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("update constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            print("update failed: \(error)")
        }
        
        return false;
    }
    
    func deleteUser(_ userId: String) {
        _checkRep()
        let row = usersTable.filter(id == userId)
        do {
            if try database.run(row.delete()) > 0 {
                print("deleted the User")
            } else {
                print("User not found")
            }
        } catch {
            print("delete failed: \(error)")
        }
        _checkRep()
    }
    
    func updateUser(_ oldUserId: String, _ newUser: User) {
        _checkRep()
        let row = usersTable.filter(id == oldUserId)
        do {
            if try database.run(row.update(id <- newUser.getUserId(), name <- newUser.getName(), password <- newUser.getPassword(), image <- newUser.getPhotoAsPath())) > 0 {
                print("Old User is updated")
            } else {
                print("Old User not found")
            }
        } catch let Result.error(message, code, statement) where code == SQLITE_CONSTRAINT {
            print("update constraint failed: \(message), in \(String(describing: statement))")
        } catch let error {
            print("update failed: \(error)")
        }
        _checkRep()
    }
    
    func searchWithKeyword(_ keyword: String) -> [User] {
        var users = [User]()
        let query = usersTable.filter(name.like("%\(keyword)%"))
        do {
            for user in try database.prepare(query) {
                let user = User(userId: user[id], name: user[name], password: user[password],photo: user[image])
                users.append(user)
            }
        } catch let error {
            print("failed to get row: \(error)")
        }
        
        return users
    }
    
    /**
     * Test functions - to be removed
     */
    
    // MARK: Only for test purpose
    private func removeDB() {
        print("Remove DB called")
        let documentDirectory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        if let fileUrl = documentDirectory?.appendingPathComponent(Constants.Tables.users).appendingPathExtension("sqlite3") {
            try? FileManager.default.removeItem(at: fileUrl)
        }
    }
    
    // Only for testing
    
    private func prepopulate(_ users: [User]) {
        _checkRep()
        if !users.isEmpty  {
            for user in users {
                if !containsUser(user.getUserId()) {
                    self.addUser(user)
                }
            }
        }
        _checkRep()
    }
    
    private func prepopulate() {
        _checkRep()
        for i in 0..<20 {
            if !containsUser("i") {
                let newUser = User(userId: "\(i)", name: "ReadyPlayer\(i)", password: "i", photo: "profile-example")
                self.addUser(newUser)
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
            for Id in try database.prepare(usersTable.select(id)) {
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



