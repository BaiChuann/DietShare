//
//  CameraHandler.swift
//  DietShare
//
//  Created by ZiyangMou on 25/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//
// swiftlint:disable implicitly_unwrapped_optional

import Foundation
import UIKit

class CameraHandler: NSObject {
    static let shared = CameraHandler()

    fileprivate var currentViewController: UIViewController!

    var imagePickedBlock: ((UIImage) -> Void)?
    fileprivate var pickController = UIImagePickerController()

    func camera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            pickController.delegate = self
            pickController.sourceType = .camera
            currentViewController.present(pickController, animated: true, completion: nil)
        }
    }
    
    func photoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            pickController.delegate = self
            pickController.sourceType = .photoLibrary
            currentViewController.present(pickController, animated: true, completion: nil)
        }
    }

    func showActionSheet(viewController: UIViewController) {
        currentViewController = viewController
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.camera()
        }))

        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.photoLibrary()
        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        viewController.present(actionSheet, animated: true, completion: nil)
    }

}

extension CameraHandler: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        currentViewController.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.imagePickedBlock?(image)
        } else {
            print("fatalError")
        }
        currentViewController.dismiss(animated: true, completion: nil)
    }
}
