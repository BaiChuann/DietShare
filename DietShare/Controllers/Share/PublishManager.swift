//
//  PublishManager.swift
//  DietShare
//
//  Created by ZiyangMou on 14/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import FacebookShare

class PublishManager: NSObject, NSCoding {
    func encode(with aCoder: NSCoder) {
        aCoder.encode(restaurantId)
    }

    required init?(coder aDecoder: NSCoder) {
        aDecoder.decodeObject()
    }

    static let shared = PublishManager()

    private var text: String = ""
    private var image: UIImage!
    private var restaurantId: String = "-1"
    private var topicsId: [String] = []
    private var rating: Int = 0
    private var options: Set<PublishOption> = []

    private let facebookURL = NSURL(string: "fbauth2:/")
    private let notificationCenter = NotificationCenter.default
    private let postManager = PostManager.shared

    private override init() {}

    func post(text: String = "", image: UIImage, restaurantId: String = "-1", topicsId: [String] = [], rating: Int = 0, additionalOption: Set<PublishOption> = []) {
        self.text = text
        self.image = image
        self.restaurantId = restaurantId
        self.topicsId = topicsId
        self.rating = rating
        self.options = additionalOption

        if options.contains(.facebook) {
            _ = postOnFacebook()
        }
        saveToPhone()
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
        let restaurantId = self.restaurantId == "-1" ? nil : self.restaurantId
        let topicsId = self.topicsId.isEmpty ? nil : self.topicsId

        let post = postManager.postPost(caption: text, time: Date(), photo: image, restaurant: restaurantId, topics: topicsId)
    }

    private func saveToPhone() {
        print(image)
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }

    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            notificationCenter.post(name: .didSaveToPhoneFail, object: nil)
        } else {
            notificationCenter.post(name: .didSaveToPhoneSuccess, object: nil)
        }
    }
}

enum PublishOption {
    case facebook
    case wechat
}
