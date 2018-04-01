//
//  TopicCell.swift
//  DietShare
//
//  Created by BaiChuan on 31/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class TopicCell: UICollectionViewCell {

    @IBOutlet weak private var topicLabel: UILabel!
    func setLabel(_ text: String) {
        topicLabel.text = text
    }
}
