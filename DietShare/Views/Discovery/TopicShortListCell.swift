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
    
    @IBOutlet weak var imageHolder: UIView!
    @IBOutlet weak private var topicImage: UIImageView!
    @IBOutlet weak private var topicName: UILabel!
    
    func setImage(_ image: UIImage) {
        //let croppedImage = cropToBounds(image, Double(topicImage.frame.width), Double(topicImage.frame.height))
        let alpha = CGFloat(Constants.DiscoveryPage.shortListCellAlpha)
        setFittedImageAsSubview(view: topicImage, image: image, alpha: alpha)
        addRoundedRectBackground(topicImage, Constants.defaultCornerRadius, 0, UIColor.clear.cgColor, UIColor.clear)
        addShadowToView(view: self.imageHolder, offset: 2, radius: 2)
    }
    
    func setName(_ name: String) {
        topicName.text = ""
    }

}
