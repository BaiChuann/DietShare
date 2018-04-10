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
    private var currentUser: User?
    
    private init() {
        users = [User]()
        for i in 0..<20 {
            let newUser = User(userId: "\(i)", name: "ReadyPlayer\(i)", password: "i", photo: #imageLiteral(resourceName: "profile-example"))
            users.append(newUser)
        }
    }
    
    // Singleton Instance
    static let shared = UserModelManager()
    
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
    
    func setCurrentUser(_ user: User) {
        self.currentUser = user
    }
    
    func getCurrentUser() -> User? {
        return self.currentUser
    }
    
}
