//
//  LayoutPhotoSelectorCell.swift
//  DietShare
//
//  Created by Fan Weiguang on 31/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit
import DKImagePickerController

class LayoutPhotoSelectorCell: DKAssetGroupDetailBaseCell {
    private let thumbnailImageView = UIImageView()
    private let checkView = UIImageView(image: UIImage(named: "checked"))
    private let checkViewInset: CGFloat = 5
    private let checkViewSize: CGFloat = 20
    private let alphaForNormal: CGFloat = 1
    private let alphaForSelected: CGFloat = 0.5

    class override func cellReuseIdentifier() -> String {
        return "CustomGroupDetailImageCell"
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.frame = bounds
        thumbnailImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(thumbnailImageView)

        checkView.contentMode = .bottomRight
        let x = thumbnailImageView.frame.origin.x + thumbnailImageView.bounds.width - checkViewInset - checkViewSize
        let y = thumbnailImageView.frame.origin.y + thumbnailImageView.bounds.height - checkViewInset - checkViewSize
        checkView.frame = CGRect(x: x, y: y, width: checkViewSize, height: checkViewSize)
        checkView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(checkView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("LayoutPhotoSelectorCell has not been implemented")
    }

    override var thumbnailImage: UIImage? {
        didSet {
            thumbnailImageView.image = thumbnailImage
        }
    }

    override var isSelected: Bool {
        didSet {
            if super.isSelected {
                self.thumbnailImageView.alpha = alphaForSelected
                self.checkView.isHidden = false
            } else {
                self.thumbnailImageView.alpha = alphaForNormal
                self.checkView.isHidden = true
            }
        }
    }

}
