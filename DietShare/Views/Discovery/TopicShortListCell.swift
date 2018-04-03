//
//  TopicListCell.swift
//  DietShare
//
//  Created by Shuang Yang on 27/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

class TopicShortListCell: UICollectionViewCell {
    
    @IBOutlet weak private var topicImage: UIImageView!
    @IBOutlet weak private var topicName: UILabel!
    
    
    func setImage(_ image: UIImage) {
        let croppedImage = cropToBounds(image, Double(topicImage.frame.width), Double(topicImage.frame.height))
        topicImage.image = croppedImage
        topicImage.alpha = CGFloat(Constants.DiscoveryPage.shortListCellAlpha)
    }
    
    func setName(_ name: String) {
        topicName.text = name
        addRoundedRectBackground(topicName, Constants.defaultCornerRadius, Constants.defaultLabelBorderWidth, UIColor.white.cgColor, UIColor.clear)
//        topicName.backgroundColor = .white
    }
    
}
