//
//  ReadOnlyTopic.swift
//  DietShare
//
//  Created by Shuang Yang on 26/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

/**
 * A read-only immutable protocol for a Topic in the app.
 * Implementations should guarantee: details are present and not null, field values are validated.
 */
protocol ReadOnlyTopic: Comparable {
    func getID() -> String
    func getName() -> String
    func getImageAsUIImage() -> UIImage
    func getDescription() -> String
    func getPopularity() -> Int
    func getPostsID() -> StringList
    func getFollowersID() -> StringList
}
