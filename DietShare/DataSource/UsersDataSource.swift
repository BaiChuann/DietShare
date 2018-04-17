//
//  UsersDataSource.swift
//  DietShare
//
//  Created by Shuang Yang on 11/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation

/**
 * A protocol for a data source for users only.
 * Implementations should guarantee: details are present and not null, field values are validated.
 */
protocol UsersDataSource {
    func getAllUsers() -> [User]
    func getNumOfUsers() -> Int
    func addUser(_ newTopic: User)
    func addUsers(_ newUsers: [User])
    func deleteUser(_ newUserID: String)
    func updateUser(_ oldUserID: String, _ newUser: User)
    func searchWithKeyword(_ keyword: String) -> [User]
    func getUserFromID(_ ID: String) -> User?
}
