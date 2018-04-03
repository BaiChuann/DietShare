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
    @IBOutlet weak private var backButton: UIButton!
    @IBOutlet weak private var nextButton: UIButton!
    @IBOutlet weak private var previewCollectionView: UICollectionView!

    private let pickerController = DKImagePickerController()
    private let minNumberOfImages = 2
    private let maxNumberOfImages = 4
    private let previewCellIdentifier = "LayoutPhotoPreviewCell"
    private var selectedImages = [UIImage]()
    
    var layoutType: Int? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        enableNextButton(shouldEnable: false)
        setUpUI()
    }

    override func viewWillLayoutSubviews() {
        if let pickerView = pickerController.view {
            let spacing: CGFloat = 5
            let startingY = backButton.frame.maxY + spacing
            let height = preview.frame.origin.y - startingY
            pickerView.frame = CGRect(x: 0, y: startingY, width: view.bounds.width, height: height)

            pickerView.backgroundColor = Constants.photoLibraryBackgroundColor
            view.addSubview(pickerView)
        }

        pickerController.selectedChanged = { [unowned self] in
            self.updateSelection()
        }
    }

    private func setUpUI() {
        nextButton.layer.cornerRadius = Constants.cornerRadius
        pickerController.inline = true
        pickerController.sourceType = .photo
        pickerController.assetType = .allPhotos
        pickerController.UIDelegate = LayoutPhotoSelectorUIDelegate()
        pickerController.maxSelectableCount = maxNumberOfImages
    }

    private func updateSelection() {
        var images = [UIImage]()
        pickerController.selectedAssets.forEach {
            $0.fetchOriginalImage(true) { image, _ in
                if let image = image {
                    images.append(image)
                }
            }
        }
        selectedImages = images

        enableNextButton(shouldEnable: selectedImages.count > minNumberOfImages)
        previewCollectionView.reloadData()
    }

    private func enableNextButton(shouldEnable: Bool) {
        nextButton.isEnabled = shouldEnable

        if shouldEnable {
            nextButton.alpha = 1
        } else {
            nextButton.alpha = 0.5
        }
    }

    @IBAction func onBackButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func onNextButtonPressed(_ sender: Any) {
        //dismiss(animated: true, completion: nil)
        
    }
}

extension LayoutPhotoSelectorController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: previewCellIdentifier, for: indexPath)

        guard let previewCell = cell as? LayoutPhotoPreviewCell else {
            return cell
        }

        let image = selectedImages[indexPath.item]
        previewCell.setImage(image)

        return previewCell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = previewCollectionView.bounds.height
        return CGSize(width: size, height: size)
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
}

extension LayoutPhotoSelectorController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "nextLayoutSelection" {
            if let toViewController = segue.destination as? PhotoModifierController {
                toViewController.selectedImages = selectedImages
                toViewController.selectedLayoutType = layoutType
            }
        }
    }
}
