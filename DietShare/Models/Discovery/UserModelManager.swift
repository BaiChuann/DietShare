//
//  UserManager.swift
//  DietShare
//
//  Created by Shuang Yang on 6/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation

class UserModelManager {
    
    private var usersDataSource: UsersDataSource
    private var users: [User] {
        return usersDataSource.getAllUsers()
    }
    private var currentUser: User?
    
    private init() {
        self.usersDataSource = UsersLocalDataSource.shared
    }
    
    // Singleton Instance
    static let shared = UserModelManager()
    
    public func getUsers() -> [User] {
        return self.users
    }
    
    public func getUserFromID(_ ID: String) -> User? {
        return usersDataSource.getUserFromID(ID)
    }
    
    func setCurrentUser(_ user: User) {
        self.currentUser = user
    }
    
    func getCurrentUser() -> User? {
        print("current user is : \(currentUser?.getUserId())")
        return self.currentUser
    }
    
    func addUser(_ user: User) {
        self.usersDataSource.addUser(user)
    }
    
    func deleteUser(_ user: User) {
        self.usersDataSource.deleteUser(user.getUserId())
    }
    
}
