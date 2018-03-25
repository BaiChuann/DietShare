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
    }
    private func adjustSize(image: UIImage) {
        let containerView = UIView(frame: CGRect(x:0,y:0,width:320,height:500))
        let imageView = UIImageView()
        
        if let image = UIImage(named: "a_image") {
            let ratio = image.size.width / image.size.height
            if containerView.frame.width > containerView.frame.height {
                let newHeight = containerView.frame.width / ratio
                imageView.frame.size = CGSize(width: containerView.frame.width, height: newHeight)
            }
            else{
                let newWidth = containerView.frame.height * ratio
                imageView.frame.size = CGSize(width: newWidth, height: containerView.frame.height)
            }
        }
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
