//
//  User.swift
//  DietShare
//
//  Created by BaiChuan on 24/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//
import UIKit

class User {
    private var userId: String
    private var name: String
    private var password: String
    private var photo: UIImage
    init(userId: String, name: String, password: String, photo: UIImage) {
        self.userId = userId
        self.name = name
        self.password = password
        self.photo = photo
    }
    func getUserId() -> String {
        return userId
    }
    func getName() -> String {
        return name
    }
    func setName(_ name: String) {
        self.name = name
    }
    func getPassword() -> String {
        return password
    }
    func setPassword(_ password: String) {
        self.password = password
    }
    func getPhoto() -> UIImage {
        return photo
    }
    func setPhoto(_ photo: UIImage) {
        self.photo = photo
    }
}
