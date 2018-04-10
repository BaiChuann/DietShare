//
//  TextColorCell.swift
//  DietShare
//
//  Created by Fan Weiguang on 9/4/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class TextColorCell: UICollectionViewCell {
    @IBOutlet weak private var colorView: TextColorCell!

    private let inset: CGFloat = 8

    override var isSelected: Bool {
        didSet {
            var newFrame = CGRect.zero
            if super.isSelected {
                newFrame = CGRect(x: 0, y: 0, width: contentView.bounds.width, height: contentView.bounds.height)
            } else {
                newFrame = CGRect(x: inset, y: inset, width: contentView.bounds.width - 2 * inset, height: contentView.bounds.height - 2 * inset)
            }

            UIView.animate(withDuration: 0.3) {
                self.colorView.frame = newFrame
                self.colorView.layer.cornerRadius = newFrame.width / 2
            }
        }
    }

    func setColor(_ color: UIColor) {
        colorView.layer.cornerRadius = colorView.frame.width / 2
        colorView.backgroundColor = color

        if color.equals(UIColor.white) {
            colorView.layer.borderColor = Constants.lightBackgroundColor.cgColor
            colorView.layer.borderWidth = 2
        }
    }
}
