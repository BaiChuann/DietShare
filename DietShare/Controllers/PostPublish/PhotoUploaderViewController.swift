//
//  PhotoUploaderViewController.swift
//  DietShare
//
//  Created by ZiyangMou on 24/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import UIKit

class PhotoUploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet private var imagePicked: UIImageView!
    let imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.delegate = self
        CameraHandler.shared.showActionSheet(viewController: self)
        CameraHandler.shared.imagePickedBlock = { image in
           self.imagePicked.image = image
        }
        /*let cameraViewController = CameraViewController { [weak self] image, asset in
            self?.imagePicked.image = image
            self?.dismiss(animated: true, completion: nil)
        }
        present(cameraViewController, animated: true, completion: nil)*/
    }
}

extension PhotoUploadViewController {
    @IBAction func openCameraButton(sender: AnyObject) {
        CameraHandler.shared.camera()
    }

    @IBAction func openPhotoLibraryButton(sender: AnyObject) {
        CameraHandler.shared.photoLibrary()
    }
}
