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
    private var checkView = UIImageView(image: UIImage(named: "checked"))

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let inset: CGFloat = 5
        let size = optionImage.bounds.width - inset
        checkView.frame = CGRect(x: 0, y: 0, width: size, height: size)
        checkView.contentMode = .bottomRight
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

    func setOptionImage(_ image: UIImage) {
        optionImage.image = image
    }

    func clearImage() {
        optionImage.image = nil
    }
}
