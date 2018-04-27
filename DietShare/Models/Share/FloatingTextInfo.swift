//
//  FloatingTextInfo.swift
//  DietShare
//
//  Created by Fan Weiguang on 13/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

/*
 Stores the info of a floating text. It is a class instead of a struct because the info
 should be able to mutate whenever user wants. Value types like struct would not be necessary.
 */
class FloatingTextInfo {
    var text: String
    var color: UIColor
    var font: UIFont
    var size: CGFloat
    var label: UILabel

    init(text: String, color: UIColor, font: UIFont, size: CGFloat, label: UILabel) {
        self.text = text
        self.color = color
        self.font = font
        self.label = label
        self.size = size
    }
}
