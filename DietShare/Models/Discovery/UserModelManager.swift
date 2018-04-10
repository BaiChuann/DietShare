//
//  UserManager.swift
//  DietShare
//
//  Created by Shuang Yang on 6/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation

class UserModelManager {
    
    private var users: [User]
    
    private init() {
        users = [User]()
        for i in 0..<20 {
            let newUser = User(userId: "\(i)", name: "Tyrion", password: "12345678", photo: #imageLiteral(resourceName: "profile-example"))
            users.append(newUser)
        }
    }
    
    static let shared = UserModelManager()
    static var currentUser = User(userId: "1", name: "Anonymous", password: "0000", photo: #imageLiteral(resourceName: "profile"))
    
    public func getUsers() -> [User] {
        return self.users
    }
    
    public func getUserFromID(_ ID: String) -> User? {
        for user in users {
            if ID == user.getUserId() {
                return user
            }
        }
        return nil
    }
    
    static func setCurrentUser(_ user: User) {
        self.currentUser = user
    }
    
    static func getCurrentUser() -> User {
        return self.currentUser
    }
    
}
