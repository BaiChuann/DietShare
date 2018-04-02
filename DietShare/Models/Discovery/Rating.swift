//
//  Rating.swift
//  DietShare
//
//  Created by Shuang Yang on 29/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation

class Rating {
    private let id: String
    private let userID: String
    private let score: Double
    
    init(_ id: String, _ userID: String, _ score: Double) {
        self.id = id
        self.userID = userID
        self.score = score
    }
}
