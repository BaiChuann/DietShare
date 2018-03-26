//
//  ReadOnlyTopic.swift
//  DietShare
//
//  Created by Shuang Yang on 26/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation

/**
 * A read-only immutable protocol for a Topic in the app.
 * Implementations should guarantee: details are present and not null, field values are validated.
 */
protocol ReadOnlyTopic {
    func getID() -> String
    func getName() -> String
    func getPopularity() -> Int
    func getPostsID() -> [String]
    func getActiveUsersID() -> [String]
}
