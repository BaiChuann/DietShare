//
//  TextPreviewCell.swift
//  DietShare
//
//  Created by Fan Weiguang on 9/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

/*
 A cell that displays different fonts.
 */
class TextPreviewCell: UICollectionViewCell {
    @IBOutlet weak private var label: UILabel!

    func setFont(_ fontName: String) {
        if let font = UIFont(name: fontName, size: 20) {
            label.font = font
            label.adjustsFontSizeToFitWidth = true
        }
    }
}
