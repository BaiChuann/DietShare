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
    private var shareState = ShareState()
    private var pickedPhoto: UIImage?
    private var recognizedFoods: [Food] = []
    private var isToCamera = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Use yellow tint
        TGCameraColor.setTint(Constants.themeColor)

        // save image to album
        TGCamera.setOption(kTGCameraOptionSaveImageToAlbum, value: false)

        // use the original image aspect instead of square
        //TGCamera.setOption(kTGCameraOptionUseOriginalAspect, value: true)

        // hide filter button
        TGCamera.setOption(kTGCameraOptionHiddenFilterButton, value: true)

        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
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
        guard let foodSelectVC = AppStoryboard.share.instance.instantiateViewController(withIdentifier: "FoodSelectController") as? FoodSelectController else {
            print("Error when pushing food select controller")
            return
        }

        shareState.originalPhoto = pickedPhoto
        foodSelectVC.shareState = shareState
        navigationController?.pushViewController(viewController: foodSelectVC, animated: false) {
            self.isToCamera = true
        }
    }

    private func goBack() {
        isToCamera = true
        guard let currentController = tabBarController as? HomeTabBarController else {
            tabBarController?.selectedIndex = 1
            tabBarController?.tabBar.isHidden = false
            return
        }
        let lastPage = currentController.currentTab
        currentController.selectedIndex = lastPage
    }
}

extension PhotoUploadViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
