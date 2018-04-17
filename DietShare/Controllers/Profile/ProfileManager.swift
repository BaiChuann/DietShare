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
        profiles.append(Profile(userId: "3"))
        profiles.append(Profile(userId: "4"))
        profiles[0].addFollowing("2")
        profiles[0].addFollowing("3")
        profiles[0].addFollowing("4")
        profiles[1].addFollower("1")
        profiles[2].addFollower("1")
        profiles[3].addFollower("1")
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
