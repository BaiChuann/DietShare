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
    var recognizedFoods: [Food] = []

    private var isToCamera = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Use yellow tint
        TGCameraColor.setTint(Constants.themeColor)

        // save image to album
        TGCamera.setOption(kTGCameraOptionSaveImageToAlbum, value: true)

        // use the original image aspect instead of square
        //TGCamera.setOption(kTGCameraOptionUseOriginalAspect, value: true)

        // hide filter button
        TGCamera.setOption(kTGCameraOptionHiddenFilterButton, value: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isToCamera {
            openCamera()
        } else {
            goBack()
        }
    }

    func cameraDidCancel() {
        goBack()
        dismiss(animated: true)
    }

    func cameraDidSelectAlbumPhoto(_ image: UIImage!) {
        pickedPhoto = image
        goToNext()
        dismiss(animated: true)
    }

    func cameraDidTakePhoto(_ image: UIImage!) {
        pickedPhoto = image
        goToNext()
        dismiss(animated: true)
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
        present(navigationController!, animated: true) {
            self.isToCamera = false
        }
    }

    private func goToNext() {
        let foodSelectVC = AppStoryboard.share.instance.instantiateViewController(withIdentifier: "FoodSelectController")
        navigationController?.pushViewController(viewController: foodSelectVC, animated: false) {
            self.isToCamera = true
        }
    }

    private func goBack() {
        isToCamera = true
        tabBarController?.selectedIndex = 1
        tabBarController?.tabBar.isHidden = false
    }
}
