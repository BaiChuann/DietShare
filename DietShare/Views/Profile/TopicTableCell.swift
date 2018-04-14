//
//  TopicTableCell.swift
//  DietShare
//
//  Created by baichuan on 14/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class TopicTableCell: UITableViewCell {
    
    @IBOutlet weak var topicImage: UIImageView!
    @IBOutlet weak var topicName: UILabel!
    func setImage(_ image: UIImage) {
        topicImage.image = image
    }
    func setName(_ name: String) {
        topicName.text = name
    }
}
