//
//  PublishTopicCell.swift
//  DietShare
//
//  Created by ZiyangMou on 11/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

class PublishTopicCell: UITableViewCell {
    @IBOutlet private(set) var nameLabel: UILabel!
    @IBOutlet private(set) var iconView: UIImageView!
    @IBOutlet private(set) var popularityLabel: UILabel!

    func setLabelText(name: String, image: UIImage, popularity: String) {
        nameLabel.text = name
        iconView.image = image
        popularityLabel.text = popularity
    }

    func highlight() {
        nameLabel.textColor = UIColor.orange
        popularityLabel.textColor = UIColor.black
    }

    func unHightlight() {
        nameLabel.textColor = UIColor.black
        popularityLabel.textColor = UIColor.darkGray
    }
}
