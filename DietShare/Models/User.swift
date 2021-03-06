//
//  User.swift
//  DietShare
//
//  Created by BaiChuan on 24/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//
import UIKit
/**
 * overview
 * This class is an abstract datatype that represent a user.
 * This class is mutable.
 */
/**
 * specification fields
 * userId: String -- represent the unique identifier of the user.
 * name: String -- represent the user's name in this app.
 * password: String -- represent the password that the user set of authentication.
 * photo: UIImage -- represent the profile photo of the user.
 **/
class User {
    private var userId: String
    private var name: String
    private var password: String
    private var photo: String
    init(userId: String, name: String, password: String, photo: String) {
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
    func getPhotoAsImage() -> UIImage {
        if let image = UIImage(named: photo) {
            return image
        }
        return UIImage(data: Data(base64Encoded: photo, options: Data.Base64DecodingOptions.ignoreUnknownCharacters)!)!
    }
    func getPhotoAsPath() -> String {
        return self.photo
    }
    func setPhoto(_ photo: String) {
        self.photo = photo
    }
}
