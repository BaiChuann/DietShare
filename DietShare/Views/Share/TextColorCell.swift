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

    private let inset: CGFloat = 5

    override func layoutSubviews() {
        super.layoutSubviews()
        
        if colorView != nil {
            colorView.layer.cornerRadius = Constants.cornerRadius
        }
    }

    func setColor(_ color: UIColor) {
        colorView.backgroundColor = color

        if color.equals(UIColor.white) {
            colorView.layer.borderColor = Constants.lightBackgroundColor.cgColor
            colorView.layer.borderWidth = 2
        }
    }

    func setSelected(_ isSelected: Bool) {
        if isSelected == self.isSelected {
            return
        }

        var newFrame = CGRect.zero
        if isSelected {
            newFrame = CGRect(x: 0, y: 0, width: contentView.bounds.width, height: contentView.bounds.height)
        } else {
            newFrame = CGRect(x: inset, y: inset, width: contentView.bounds.width - 2 * inset, height: contentView.bounds.height - 2 * inset)
        }

        UIView.animate(withDuration: 0.3) {
            self.colorView.frame = newFrame
        }

        self.isSelected = isSelected
    }
}
