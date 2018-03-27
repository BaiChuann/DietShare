//
//  TopicListCell.swift
//  DietShare
//
//  Created by Shuang Yang on 27/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

class TopicListCell: UICollectionViewCell {
    
    @IBOutlet weak private var topicImage: UIImageView!
    @IBOutlet weak private var topicName: UILabel!
    
    func setImage(_ image: UIImage) {
        topicImage.image = image
    }
    
    func setName(_ name: String) {
        topicName.text = name
    }
    
}
