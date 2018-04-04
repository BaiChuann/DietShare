//
//  LayoutPhotoSelectorUIDelegate.swift
//  DietShare
//
//  Created by Fan Weiguang on 31/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit
import DKImagePickerController

class LayoutPhotoSelectorUIDelegate: DKImagePickerControllerDefaultUIDelegate {
    override func imagePickerControllerCollectionImageCell() -> DKAssetGroupDetailBaseCell.Type {
        return LayoutPhotoSelectorCell.self
    }
}
