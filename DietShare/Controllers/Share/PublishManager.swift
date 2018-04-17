//
//  PublishManager.swift
//  DietShare
//
//  Created by ZiyangMou on 14/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import FacebookShare

class PublishManager {
    static let shared = PublishManager()

    private var text: String = ""
    private var image: UIImage!
    private var restaurantId: String = "-1"
    private var topicsId: [String] = []
    private var rating: Double = 0.0
    private var options: Set<PublishOption> = []
    private let facebookURL = NSURL(string: "fbauth2:/")
    private let notificationCenter = NotificationCenter.default

    private init() {}

    func post(text: String = "", image: UIImage, restaurantId: String = "-1", topicsId: [String] = [], rating: Double = 0.0, additionalOption: Set<PublishOption> = []) {
        self.text = text
        self.image = image
        self.restaurantId = restaurantId
        self.topicsId = topicsId
        self.rating = rating
        self.options = additionalOption

        if options.contains(.facebook) {
            _ = postOnFacebook()
        }

        postInApp()
    }

    private func postOnFacebook() -> Bool {
        guard let facebookURL = facebookURL else {
            notificationCenter.post(name: .didFacebookShareFail, object: nil)
            return false
        }
        guard UIApplication.shared.canOpenURL(facebookURL as URL) else {
            notificationCenter.post(name: .didFacebookShareFail, object: nil)
            return false
        }

        let photo = Photo(image: image, userGenerated: true)
        let content = PhotoShareContent(photos: [photo])
        let shareDialog = ShareDialog(content: content)
        shareDialog.mode = .native
        shareDialog.failsOnInvalidData = true

        do {
            try shareDialog.show()
        } catch {
            notificationCenter.post(name: .didFacebookShareFail, object: nil)
            return false
        }
        return true
    }

    private func postInApp() {
        print("text: \(text)")
        print("image: \(image)")
        print("restaurantId: \(restaurantId)")
        print("topicsId: \(topicsId)")
        print("rating: \(rating)")
        print("options: \(options)")
    }
}

enum PublishOption {
    case facebook
    case wechat
}
