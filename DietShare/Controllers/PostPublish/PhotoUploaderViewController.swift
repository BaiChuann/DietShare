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
    private var isToCamera: Bool = true
    private var nextStoryboard: NextStoryboard = .camera
    private var recognizer = RecognitionRequester.shared

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        recognizer.post()
        
        //goToFoodSelectController()
        
        let foodSelectVC = AppStoryboard.share.instance.instantiateViewController(withIdentifier: "StickerAdderViewController")
        navigationController?.pushViewController(foodSelectVC, animated: true)

        /*switch nextStoryboard {
        case .camera:
            nextStoryboard = .discover
            openCamera()
        case .discover:
            nextStoryboard = .camera
            goBackToDiscovery()
        case .foodSelector:
            nextStoryboard = .camera
            goToFoodSelectController()
        }*/
    }

    func cameraDidCancel() {
        dismiss(animated: true, completion: nil)
    }

    func cameraDidSelectAlbumPhoto(_ image: UIImage!) {
        pickedPhoto = image
        nextStoryboard = .foodSelector
        dismiss(animated: true, completion: nil)
    }

    func cameraDidTakePhoto(_ image: UIImage!) {
        pickedPhoto = image
        nextStoryboard = .foodSelector
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
        present(navigationController!, animated: true, completion: nil)
    }

    private func goBackToDiscovery() {
        self.tabBarController?.selectedIndex = 0
    }

    
    func goToFoodSelectController() {
        let foodSelectVC = AppStoryboard.share.instance.instantiateViewController(withIdentifier: "FoodSelectController")
        navigationController?.pushViewController(foodSelectVC, animated: true)
    }

}

fileprivate enum NextStoryboard {
    case discover
    case camera
    case foodSelector
}
