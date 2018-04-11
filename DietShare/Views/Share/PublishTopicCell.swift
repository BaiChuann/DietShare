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
    @IBOutlet private(set) var label: UILabel!

    func setLabelText(text: String) {
        label.text = text
    }

    func highlight() {
        label.textColor = UIColor.orange
    }

    func unHightlight() {
        label.textColor = .black
    }
}
