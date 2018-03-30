//
//  LayoutPhotoSelectorController.swift
//  DietShare
//
//  Created by Fan Weiguang on 31/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import UIKit
import DKImagePickerController

class LayoutPhotoSelectorController: UIViewController {
    @IBOutlet weak private var preview: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let pickerController = DKImagePickerController()
        pickerController.inline = true
        pickerController.sourceType = .photo
        pickerController.assetType = .allPhotos

        if let pickerView = pickerController.view {
            pickerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: preview.frame.origin.y)
            pickerView.backgroundColor = .gray
            view.addSubview(pickerView)
        }
    }

    @IBAction func onNextButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
