//
//  PhotoUploaderViewController.swift
//  DietShare
//
//  Created by ZiyangMou on 24/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//
// swiftlint:disable implicitly_unwrapped_optional
// swiftlint:disable force_unwrapping

import Foundation
import UIKit
import TGCameraViewController

class PhotoUploadViewController: UIViewController, TGCameraDelegate {
    var pickedPhoto: UIImage?
    private var isToCamera: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Use yellow tint
        TGCameraColor.setTint(.yellow)

        // save image to album
        TGCamera.setOption(kTGCameraOptionSaveImageToAlbum, value: true)

        // use the original image aspect instead of square
        //TGCamera.setOption(kTGCameraOptionUseOriginalAspect, value: true)

        // hide filter button
        TGCamera.setOption(kTGCameraOptionHiddenFilterButton, value: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        switch isToCamera {
        case true:
            openCamera()
        case false:
            goBackToDiscovery()
        }
    }

    func cameraDidCancel() {
        dismiss(animated: true, completion: nil)
    }

    func cameraDidSelectAlbumPhoto(_ image: UIImage!) {
        pickedPhoto = image
        dismiss(animated: true, completion: nil)
    }

    func cameraDidTakePhoto(_ image: UIImage!) {
        pickedPhoto = image
        dismiss(animated: true, completion: nil)
    }

    // Optional

    func cameraWillTakePhoto() {
        print("cameraWillTakePhoto")
    }

    func cameraDidSavePhoto(atPath assetURL: URL!) {
        print("cameraDidSavePhotoAtPath: \(assetURL)")
    }

    func cameraDidSavePhotoWithError(_ error: Error!) {
        print("cameraDidSavePhotoWithError \(error)")
    }

    private func openCamera() {
        let navigationController = TGCameraNavigationController.new(with: self)
        isToCamera = false
        present(navigationController!, animated: true, completion: nil)
    }

    private func goBackToDiscovery() {
        isToCamera = true
        tabBarController?.selectedIndex = 1
    }
}
