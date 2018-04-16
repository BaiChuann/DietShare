//
//  TopicFullListCell.swift
//  DietShare
//
//  Created by Shuang Yang on 27/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

class TopicFullListCell: UICollectionViewCell {
    
    @IBOutlet weak private var topicImage: UIImageView!
    @IBOutlet weak private var topicName: UILabel!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var topicNameLabel: UILabel!
    
    func setImage(_ image: UIImage) {
        topicImage.image = image
    }
    
    func setName(_ name: String) {
        topicName.text = name
        
        topicNameLabel.text = name
        addRoundedRectBackground(topicNameLabel, Constants.defaultCornerRadius, Constants.defaultLabelBorderWidth, UIColor.white.cgColor, UIColor.clear)
    }
    
    func initFollowButtonView() {
        addRoundedRectBackground(followButton, Constants.defaultCornerRadius, Constants.defaultBottonBorderWidth, UIColor.black.cgColor, UIColor.clear)
    }
    
}
