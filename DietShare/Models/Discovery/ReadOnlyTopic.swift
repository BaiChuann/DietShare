//
//  ReadOnlyTopic.swift
//  DietShare
//
//  Created by Shuang Yang on 26/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation

protocol ReadOnlyTopic {
    func getID() -> String
    func getName() -> String
    func getPopularity() -> Int
    func getPosts() -> [String]
    func getActiveUsers() -> [String]
}
