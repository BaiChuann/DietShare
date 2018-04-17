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
    @IBOutlet weak private var nameLabel: UILabel!
    @IBOutlet weak private var popularityLabel: UILabel!
    @IBOutlet weak private var checkedLabel: UIImageView!

    func setLabelText(name: String, popularity: String) {
        nameLabel.text = name
        popularityLabel.text = popularity
        checkedLabel.isHidden = true
    }

    func highlight() {
        checkedLabel.isHidden = false
    }

    func unHightlight() {
        checkedLabel.isHidden = true
    }
}
