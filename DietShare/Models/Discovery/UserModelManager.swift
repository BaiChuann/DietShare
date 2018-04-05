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
    
}
