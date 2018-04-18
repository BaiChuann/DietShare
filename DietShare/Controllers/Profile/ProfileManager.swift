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
        prepopulate()
        
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
    func prepopulate() {
        for i in 1...10 {
            profiles.append(Profile(userId: String(i)))
        }
        for i in 2...10 {
            profiles[0].addFollowing(String(i))
            profiles[i-1].addFollower("1")
        }
    }
}
