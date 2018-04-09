//
//  PhotoOptionCell.swift
//  DietShare
//
//  Created by Fan Weiguang on 30/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit

class PhotoOptionCell: UICollectionViewCell {
    @IBOutlet weak private var optionImage: UIImageView!
    @IBOutlet weak private var label: UILabel!
    private var checkView = UIImageView(image: UIImage(named: "checked"))

    override func awakeFromNib() {
        super.awakeFromNib()

        let inset: CGFloat = 20
        let size = optionImage.bounds.width
        checkView.frame = CGRect(x: 0, y: 0, width: size, height: size - inset)
        checkView.contentMode = .center
        checkView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        checkView.backgroundColor = UIColor.clear
        checkView.isHidden = true
        contentView.addSubview(checkView)
    }

    override var isSelected: Bool {
        didSet {
            if super.isSelected {
                optionImage.alpha = 0.5
                checkView.isHidden = false
            } else {
                optionImage.alpha = 1
                checkView.isHidden = true
            }
        }
    }

    func setLabelText(_ text: String?) {
        label.text = text
    }

    func setOptionImage(_ image: UIImage) {
        optionImage.image = image
    }

    func clearImage() {
        optionImage.image = nil
    }
}
