//
//  ProfileManager.swift
//  DietShare
//
//  Created by baichun on 16/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class ProfileManager {
    private var profiles: [Profile] = []
    init() {
        profiles.append(Profile(userId: "1"))
        profiles.append(Profile(userId: "2"))
        profiles[0].addFollowing("2")
        profiles[1].addFollower("1")
    }
    static let shared = ProfileManager()
    func getProfile(_ id: String) -> Profile? {
        for profile in profiles {
            if profile.getUserId() == id {
                return profile
            }
        }
        return nil
    }
    func getFollowingUsers(_ userId: String) -> [String] {
        guard let profile = getProfile(userId) else {
            return []
        }
        let followings = profile.getFollowings()
        return followings 
    }
}
