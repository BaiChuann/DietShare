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

    private init() {}

    func post(text: String = "", image: UIImage, restaurantId: String = "-1", topicsId: [String] = [], rating: Double = 0.0, additionalOption: Set<PublishOption> = []) {
        self.text = text
        self.image = image
        self.restaurantId = restaurantId
        self.topicsId = topicsId
        self.rating = rating
        self.options = additionalOption
    }
}

enum PublishOption {
    case facebook
    case wechat
}
