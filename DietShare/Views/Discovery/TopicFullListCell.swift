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
    @IBOutlet weak var topicDescription: UILabel!
    
    func setImage(_ image: UIImage) {
        let alpha: CGFloat = 1.0
        setFittedImageAsSubview(view: topicImage, image: image, alpha: alpha)
    }
    
    func setName(_ name: String) {
        topicName.text = name
    }
    
    func setDescription(_ description: String) {
        topicDescription.text = description
    }
    
    func initFollowButtonView() {
        followButton.layer.cornerRadius = Constants.cornerRadius
        followButton.layer.borderWidth = 2
        followButton.layer.borderColor = Constants.themeColor.cgColor
//        addRoundedRectBackground(followButton, Constants.defaultCornerRadius, Constants.defaultBottonBorderWidth, UIColor.black.cgColor, UIColor.clear)
    }
    
}
